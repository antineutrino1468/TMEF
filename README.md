# README

## 1. Overview
This project focuses on analyzing user and media text data in the game industry, utilizing machine learning and text mining techniques. It includes data preprocessing, visualization, model training, transfer learning, and model extensions.

## 2. Main Features

### Data Preprocessing
- **File**: `dataPreprocessing.ipynb`

### Data Visualization
- **Files**: `Data_visualization.R`, `metadata.R`

### User Review Model Training
- **File**: `modelTraining.ipynb`

### Transfer Learning on Media Data
- **Files**: `transfer.ipynb`, `coefficient_plot.R`

### Model Extension
- **File**: `basic_model_with_emojis_emoticons.ipynb`

#### Detailed Information:
This project contains a Jupyter Notebook for training a machine learning model capable of processing text data that includes emojis and emoticons. The notebook performs text preprocessing, feature extraction, and regression modeling.

#### Features:
- Data preprocessing using `NLTK`, `SnowballStemmer`, and Regular Expressions
- Text vectorization using `CountVectorizer` and `TF-IDF Vectorizer`
- Word embedding with `Word2Vec`
- Regression modeling with `Lasso` and `Ridge Regression`
- Data visualization using `Matplotlib`

## 3. Usage
1. Load the dataset (`user_df_filtered_nplus.csv` should be placed in the same directory).
2. Run all cells in the Jupyter Notebook.

## 4. File Structure
- `basic_model_with_emojis_emoticons.ipynb` - Main Notebook file containing model training and evaluation

## 5. Custom Functions
- **Files**:
  - `myFunction.py`: Custom Python functions for text processing and feature extraction.
  - `kendall_acc.R`: Calculates Kendall’s correlation.
  - `TMEF_dfm.R`: Implements text feature extraction techniques.

## 6. Execution Steps
1. `dataPreprocessing.ipynb`
2. `Data_visualization.R`
3. `metadata.R`
4. `modelTraining.ipynb`
5. `basic_model_with_emojis_emoticons.ipynb`
6. `transfer.ipynb`
7. `coefficient_plot.R`
