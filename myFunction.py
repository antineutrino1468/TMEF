from scipy.stats import kendalltau
import numpy as np
import re
import pandas as pd
from nltk.tokenize import word_tokenize
from nltk.stem import PorterStemmer
from nltk.corpus import stopwords
from gensim.utils import simple_preprocess

# Function to compute Kendall's Tau-based accuracy metric
def kendall_acc(x, y, percentage=True):
    """
    Compute the Kendall's Tau-based accuracy metric, along with its confidence interval.
    
    Parameters:
    x (array-like): First set of rankings or predictions.
    y (array-like): Second set of rankings (ground truth).
    percentage (bool): If True, return values in percentage format (multiplied by 100).
    
    Returns:
    pd.DataFrame: A DataFrame containing the accuracy, lower bound, and upper bound of the confidence interval.
    """
    
    # Compute Kendall's Tau correlation coefficient
    tau, _ = kendalltau(x, y)
    
    # Convert Kendall's Tau to accuracy metric
    kt_acc = 0.5 + tau / 2  # Rescales Tau (-1 to 1) into an accuracy-like range (0 to 1)
    
    # Compute standard error for the accuracy estimate
    n = len(x)
    kt_se = np.sqrt((kt_acc * (1 - kt_acc)) / n)
    
    # Compute 95% confidence interval (using normal approximation)
    lower = kt_acc - 1.96 * kt_se
    upper = kt_acc + 1.96 * kt_se
    
    # Create a DataFrame to store the results
    report = pd.DataFrame({
        "acc": [kt_acc],    # Estimated accuracy
        "lower": [lower],   # Lower bound of confidence interval
        "upper": [upper]    # Upper bound of confidence interval
    }).round(4)
    
    # Convert values to percentages if specified
    if percentage:
        report *= 100
    
    return report

# Function to check if a user review is meaningful
def is_meaningful_review(review):
    """
    Determines whether a given review is meaningful based on several criteria.

    Parameters:
    review (str): The user review to evaluate.

    Returns:
    bool: True if the review is meaningful, False otherwise.
    """

    # Check if the review is empty or NaN
    if pd.isna(review) or str(review).strip() == "":
        return False
    
    # Convert to string and remove leading/trailing whitespaces
    review = str(review).strip()
    
    # Filter out reviews that contain only URLs
    if re.match(r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[^\s]*', review):
        return False
    
    # Remove reviews containing excessive character repetition (e.g., "EEEEE" or "woooowww")
    if re.search(r'(.)\1{2,}', review.lower()):
        return False
    
    # Tokenize the review and count words/characters
    word_count = len(word_tokenize(review))  # Number of words
    char_count = len(review)  # Number of characters
    
    # Discard reviews that are too short (less than 5 characters or words)
    if char_count < 5 or word_count < 5:
        return False
    
    # Remove common stopwords (e.g., "the", "is", "and") to check if meaningful words remain
    stop_words = set(stopwords.words('english'))
    words = [word.lower() for word in word_tokenize(review) if word.lower() not in stop_words]
    
    # If all remaining words are meaningless (e.g., extremely short words like "a", "ok"),
    # the review is considered uninformative
    if not words or all(len(word) <= 2 for word in words):
        return False
    
    return True


# Function to clean text by removing URLs, punctuation, and numbers
def clean_text(text):
    """
    Cleans the input text by:
    - Converting to lowercase
    - Removing URLs
    - Removing punctuation
    - Removing numbers
    - Stripping extra spaces

    Parameters:
    text (str): The input text to clean.

    Returns:
    str: The cleaned text.
    """
    # Convert text to lowercase
    text = str(text).lower()
    
    # Remove URLs (e.g., "http://XXX")
    text = re.sub(r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[^\s]*', '', text)
    
    # Remove punctuation (keeping only words and spaces)
    text = re.sub(r'[^\w\s]', '', text)
    
    # Remove numbers
    text = re.sub(r'\d+', '', text)
    
    # Remove leading/trailing whitespace and return
    return text.strip()

# Initialize Porter Stemmer for stemming
ps = PorterStemmer()

# Function to perform stemming on text
def stem_text(text):
    """
    Applies stemming to each word in the input text using the Porter Stemmer.

    Parameters:
    text (str): The input text to stem.

    Returns:
    str: The text after stemming.
    """
    # Tokenize the text into words
    words = word_tokenize(text)
    
    # Apply stemming to each word
    stemmed_words = [ps.stem(word) for word in words]
    
    # Join words back into a single string
    return " ".join(stemmed_words)

# Function to get a sentence embedding from a Word2Vec model
def get_sentence_embedding(review, model, vector_size=100):
    """
    Converts a text review into a numerical embedding using a trained Word2Vec model.

    Parameters:
    review (str): The input text (a single review).
    model (Word2Vec): A trained Word2Vec model.
    vector_size (int): The size of the word vectors (default is 100).

    Returns:
    np.ndarray: A vector of size (vector_size,), representing the sentence embedding.
    """
    
    # Preprocess the review (tokenization, lowercasing, removing special characters, etc.)
    words = simple_preprocess(review)

    # Extract word vectors for words that exist in the Word2Vec vocabulary
    word_vectors = [model.wv[word] for word in words if word in model.wv]
    
    # If no words in the review are found in the vocabulary, return a zero vector
    if len(word_vectors) == 0:
        return np.zeros(vector_size)

    # Compute the mean of all word vectors in the review to get a sentence-level embedding
    return np.mean(word_vectors, axis=0)

# Function to tokenize a list of reviews
def tokenize_reviews(reviews):
    """
    Tokenizes a list of text reviews by preprocessing each review.

    Parameters:
    reviews (list of str): A list of text reviews.

    Returns:
    list of list of str: A list where each review is represented as a list of preprocessed words.
    """
    
    # Apply simple_preprocess to each review (lowercasing, removing punctuation, tokenizing)
    return [simple_preprocess(review) for review in reviews]
