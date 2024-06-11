{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "baae7d6c",
   "metadata": {
    "_execution_state": "idle",
    "_uuid": "051d70d956493feee0c6d64651c6a088724dca2a",
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:43.561616Z",
     "iopub.status.busy": "2024-06-11T15:35:43.558485Z",
     "iopub.status.idle": "2024-06-11T15:35:44.827629Z",
     "shell.execute_reply": "2024-06-11T15:35:44.825362Z"
    },
    "papermill": {
     "duration": 1.281616,
     "end_time": "2024-06-11T15:35:44.830676",
     "exception": false,
     "start_time": "2024-06-11T15:35:43.549060",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "── \u001b[1mAttaching core tidyverse packages\u001b[22m ──────────────────────── tidyverse 2.0.0 ──\n",
      "\u001b[32m✔\u001b[39m \u001b[34mdplyr    \u001b[39m 1.1.4     \u001b[32m✔\u001b[39m \u001b[34mreadr    \u001b[39m 2.1.4\n",
      "\u001b[32m✔\u001b[39m \u001b[34mforcats  \u001b[39m 1.0.0     \u001b[32m✔\u001b[39m \u001b[34mstringr  \u001b[39m 1.5.1\n",
      "\u001b[32m✔\u001b[39m \u001b[34mggplot2  \u001b[39m 3.4.4     \u001b[32m✔\u001b[39m \u001b[34mtibble   \u001b[39m 3.2.1\n",
      "\u001b[32m✔\u001b[39m \u001b[34mlubridate\u001b[39m 1.9.3     \u001b[32m✔\u001b[39m \u001b[34mtidyr    \u001b[39m 1.3.0\n",
      "\u001b[32m✔\u001b[39m \u001b[34mpurrr    \u001b[39m 1.0.2     \n",
      "── \u001b[1mConflicts\u001b[22m ────────────────────────────────────────── tidyverse_conflicts() ──\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mfilter()\u001b[39m masks \u001b[34mstats\u001b[39m::filter()\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mlag()\u001b[39m    masks \u001b[34mstats\u001b[39m::lag()\n",
      "\u001b[36mℹ\u001b[39m Use the conflicted package (\u001b[3m\u001b[34m<http://conflicted.r-lib.org/>\u001b[39m\u001b[23m) to force all conflicts to become errors\n"
     ]
    },
    {
     "data": {
      "text/html": [],
      "text/latex": [],
      "text/markdown": [],
      "text/plain": [
       "character(0)"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# This R environment comes with many helpful analytics packages installed\n",
    "# It is defined by the kaggle/rstats Docker image: https://github.com/kaggle/docker-rstats\n",
    "# For example, here's a helpful package to load\n",
    "\n",
    "library(tidyverse) # metapackage of all tidyverse packages\n",
    "\n",
    "# Input data files are available in the read-only \"../input/\" directory\n",
    "# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory\n",
    "\n",
    "list.files(path = \"../input\")\n",
    "\n",
    "# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using \"Save & Run All\" \n",
    "# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 2,
   "id": "f44ddb69",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:44.880852Z",
     "iopub.status.busy": "2024-06-11T15:35:44.843694Z",
     "iopub.status.idle": "2024-06-11T15:35:47.671809Z",
     "shell.execute_reply": "2024-06-11T15:35:47.669394Z"
    },
    "papermill": {
     "duration": 2.839845,
     "end_time": "2024-06-11T15:35:47.675876",
     "exception": false,
     "start_time": "2024-06-11T15:35:44.836031",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Loading required package: lattice\n",
      "\n",
      "\n",
      "Attaching package: ‘caret’\n",
      "\n",
      "\n",
      "The following object is masked from ‘package:purrr’:\n",
      "\n",
      "    lift\n",
      "\n",
      "\n",
      "The following object is masked from ‘package:httr’:\n",
      "\n",
      "    progress\n",
      "\n",
      "\n"
     ]
    }
   ],
   "source": [
    "library(titanic)    # loads titanic_train data frame\n",
    "library(caret)\n",
    "library(tidyverse)\n",
    "library(rpart)\n",
    "\n",
    "# 3 significant digits\n",
    "options(digits = 3)\n",
    "\n",
    "# clean the data - `titanic_train` is loaded with the titanic package\n",
    "titanic_clean <- titanic_train %>%\n",
    "    mutate(Survived = factor(Survived),\n",
    "           Embarked = factor(Embarked),\n",
    "           Age = ifelse(is.na(Age), median(Age, na.rm = TRUE), Age), # NA age to median age\n",
    "           FamilySize = SibSp + Parch + 1) %>%    # count family members\n",
    "    select(Survived,  Sex, Pclass, Age, Fare, SibSp, Parch, FamilySize, Embarked)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "id": "89f74242",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:47.691617Z",
     "iopub.status.busy": "2024-06-11T15:35:47.689870Z",
     "iopub.status.idle": "2024-06-11T15:35:47.758236Z",
     "shell.execute_reply": "2024-06-11T15:35:47.756116Z"
    },
    "papermill": {
     "duration": 0.079505,
     "end_time": "2024-06-11T15:35:47.761129",
     "exception": false,
     "start_time": "2024-06-11T15:35:47.681624",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "712"
      ],
      "text/latex": [
       "712"
      ],
      "text/markdown": [
       "712"
      ],
      "text/plain": [
       "[1] 712"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "179"
      ],
      "text/latex": [
       "179"
      ],
      "text/markdown": [
       "179"
      ],
      "text/plain": [
       "[1] 179"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "273"
      ],
      "text/latex": [
       "273"
      ],
      "text/markdown": [
       "273"
      ],
      "text/plain": [
       "[1] 273"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "0.383426966292135"
      ],
      "text/latex": [
       "0.383426966292135"
      ],
      "text/markdown": [
       "0.383426966292135"
      ],
      "text/plain": [
       "[1] 0.383"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q1. Split titanic_clean into test and training sets - after running the setup code, it should have 891 rows and 9 variables.\n",
    "#Set the seed to 42, then use the caret package to create a 20% data partition based on the Survived column. Assign the 20% partition to test_set and the remaining 80% partition to train_set.\n",
    "#How many observations are in the training set?\n",
    "#How many observations are in the test set?\n",
    "#What proportion of individuals in the training set survived??\n",
    "\n",
    "set.seed(42)\n",
    "index <- createDataPartition(titanic_clean$Survived, p = 0.2, list = FALSE)\n",
    "\n",
    "train_set <- titanic_clean[-index, ]\n",
    "test_set <- titanic_clean[index, ]\n",
    "\n",
    "#Train set\n",
    "nrow(train_set)\n",
    "\n",
    "#Test set\n",
    "nrow(test_set)\n",
    "\n",
    "\n",
    "#Proportions of individuals that survived in the training set\n",
    "survived <- sum(train_set$Survived == 1)\n",
    "survived\n",
    "total_train <-nrow(train_set)\n",
    "proportion_survived <- survived / total_train\n",
    "proportion_survived"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "id": "ff80f90a",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:47.778318Z",
     "iopub.status.busy": "2024-06-11T15:35:47.776344Z",
     "iopub.status.idle": "2024-06-11T15:35:47.804953Z",
     "shell.execute_reply": "2024-06-11T15:35:47.802768Z"
    },
    "papermill": {
     "duration": 0.040129,
     "end_time": "2024-06-11T15:35:47.807608",
     "exception": false,
     "start_time": "2024-06-11T15:35:47.767479",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "0.541899441340782"
      ],
      "text/latex": [
       "0.541899441340782"
      ],
      "text/markdown": [
       "0.541899441340782"
      ],
      "text/plain": [
       "[1] 0.542"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q2The simplest prediction method is randomly guessing the outcome without using additional predictors. These methods will help us determine whether our machine learning algorithm performs better than chance. How accurate are two methods of guessing Titanic passenger survival?\n",
    "#Set the seed to 3. For each individual in the test set, randomly guess whether that person survived or not by sampling from the vector c(0,1) (Note: use the default argument setting of prob from the sample function).\n",
    "#What is the accuracy of this guessing method?\n",
    "\n",
    "set.seed(3)\n",
    "\n",
    "guess <- sample(c(0,1), nrow(test_set), replace = TRUE)\n",
    "mean(guess == test_set$Survived)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "44bb06d3",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:47.825486Z",
     "iopub.status.busy": "2024-06-11T15:35:47.823420Z",
     "iopub.status.idle": "2024-06-11T15:35:47.926537Z",
     "shell.execute_reply": "2024-06-11T15:35:47.924458Z"
    },
    "papermill": {
     "duration": 0.115117,
     "end_time": "2024-06-11T15:35:47.929247",
     "exception": false,
     "start_time": "2024-06-11T15:35:47.814130",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "0.733067729083665"
      ],
      "text/latex": [
       "0.733067729083665"
      ],
      "text/markdown": [
       "0.733067729083665"
      ],
      "text/plain": [
       "[1] 0.733"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "0.193058568329718"
      ],
      "text/latex": [
       "0.193058568329718"
      ],
      "text/markdown": [
       "0.193058568329718"
      ],
      "text/plain": [
       "[1] 0.193"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 2 × 2</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>Sex</th><th scope=col>proportion_survived</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>female</td><td>0.733</td></tr>\n",
       "\t<tr><td>male  </td><td>0.193</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 2 × 2\n",
       "\\begin{tabular}{ll}\n",
       " Sex & proportion\\_survived\\\\\n",
       " <chr> & <dbl>\\\\\n",
       "\\hline\n",
       "\t female & 0.733\\\\\n",
       "\t male   & 0.193\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 2 × 2\n",
       "\n",
       "| Sex &lt;chr&gt; | proportion_survived &lt;dbl&gt; |\n",
       "|---|---|\n",
       "| female | 0.733 |\n",
       "| male   | 0.193 |\n",
       "\n"
      ],
      "text/plain": [
       "  Sex    proportion_survived\n",
       "1 female 0.733              \n",
       "2 male   0.193              "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q3a. Use the training set to determine whether members of a given sex were more likely to survive or die.\n",
    "#What proportion of training set females survived? \n",
    "#What proportion of training set males survived?\n",
    "\n",
    "\n",
    "train_set$Survived <- as.numeric(train_set$Survived) - 1\n",
    "proportion_female_survived <- mean(train_set$Survived[train_set$Sex == \"female\"], na.rm = TRUE)\n",
    "\n",
    "proportion_male_survived <- mean(train_set$Survived[train_set$Sex == \"male\"], na.rm = TRUE)\n",
    "\n",
    "proportion_female_survived\n",
    "proportion_male_survived\n",
    "\n",
    "#method 2\n",
    "library(dplyr)\n",
    "\n",
    "proportions <- train_set %>%\n",
    "  group_by(Sex) %>%\n",
    "  summarise(proportion_survived = mean(as.numeric(Survived)), .groups = \"drop\")\n",
    "proportions\n",
    "\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "id": "ceb0ca1b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:47.947965Z",
     "iopub.status.busy": "2024-06-11T15:35:47.946032Z",
     "iopub.status.idle": "2024-06-11T15:35:47.974918Z",
     "shell.execute_reply": "2024-06-11T15:35:47.972197Z"
    },
    "papermill": {
     "duration": 0.042022,
     "end_time": "2024-06-11T15:35:47.978351",
     "exception": false,
     "start_time": "2024-06-11T15:35:47.936329",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "0.810055865921788"
      ],
      "text/latex": [
       "0.810055865921788"
      ],
      "text/markdown": [
       "0.810055865921788"
      ],
      "text/plain": [
       "[1] 0.81"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q3b. Predict survival using sex on the test set: if the survival rate for a sex is over 0.5, predict survival for all individuals of that sex, and predict death if the survival rate for a sex is under 0.5.\n",
    "#What is the accuracy of this sex-based prediction method on the test set?\n",
    "\n",
    "sex_model <- ifelse(test_set$Sex == \"female\", 1, 0)  \n",
    "mean(sex_model == test_set$Survived) \n",
    "\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "id": "5b44b668",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:47.997776Z",
     "iopub.status.busy": "2024-06-11T15:35:47.995872Z",
     "iopub.status.idle": "2024-06-11T15:35:48.036440Z",
     "shell.execute_reply": "2024-06-11T15:35:48.033473Z"
    },
    "papermill": {
     "duration": 0.053973,
     "end_time": "2024-06-11T15:35:48.039840",
     "exception": false,
     "start_time": "2024-06-11T15:35:47.985867",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "1"
      ],
      "text/latex": [
       "1"
      ],
      "text/markdown": [
       "1"
      ],
      "text/plain": [
       "[1] 1"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q4a. In the training set, which class(es) (Pclass) were passengers more likely to survive than die? Note that \"more likely to survive than die\" (probability > 50%) is distinct from \"equally likely to survive or die\" (probability = 50%).\n",
    "\n",
    "survival_rates <- aggregate(Survived ~ Pclass, data = train_set, FUN = function(x) mean(x == 1))\n",
    "\n",
    "classes_more_likely_to_survive <- survival_rates$Pclass[survival_rates$Survived > 0.5]\n",
    "\n",
    "classes_more_likely_to_survive\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "24f56f2d",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:48.060149Z",
     "iopub.status.busy": "2024-06-11T15:35:48.058163Z",
     "iopub.status.idle": "2024-06-11T15:35:48.086200Z",
     "shell.execute_reply": "2024-06-11T15:35:48.083366Z"
    },
    "papermill": {
     "duration": 0.041985,
     "end_time": "2024-06-11T15:35:48.089532",
     "exception": false,
     "start_time": "2024-06-11T15:35:48.047547",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "0.681564245810056"
      ],
      "text/latex": [
       "0.681564245810056"
      ],
      "text/markdown": [
       "0.681564245810056"
      ],
      "text/plain": [
       "[1] 0.682"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q4b. Predict survival using passenger class on the test set: predict survival if the survival rate for a class is over 0.5, otherwise predict death.\n",
    "#What is the accuracy of this class-based prediction method on the test set?\n",
    "\n",
    "\n",
    "class_model <- ifelse(test_set$Pclass == 1, 1, 0)  \n",
    "mean(class_model == test_set$Survived) \n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "b4320548",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:48.109952Z",
     "iopub.status.busy": "2024-06-11T15:35:48.107944Z",
     "iopub.status.idle": "2024-06-11T15:35:48.150923Z",
     "shell.execute_reply": "2024-06-11T15:35:48.148058Z"
    },
    "papermill": {
     "duration": 0.057209,
     "end_time": "2024-06-11T15:35:48.154659",
     "exception": false,
     "start_time": "2024-06-11T15:35:48.097450",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A data.frame: 2 × 2</caption>\n",
       "<thead>\n",
       "\t<tr><th></th><th scope=col>Sex</th><th scope=col>Pclass</th></tr>\n",
       "\t<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><th scope=row>1</th><td>female</td><td>1</td></tr>\n",
       "\t<tr><th scope=row>3</th><td>female</td><td>2</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A data.frame: 2 × 2\n",
       "\\begin{tabular}{r|ll}\n",
       "  & Sex & Pclass\\\\\n",
       "  & <chr> & <int>\\\\\n",
       "\\hline\n",
       "\t1 & female & 1\\\\\n",
       "\t3 & female & 2\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A data.frame: 2 × 2\n",
       "\n",
       "| <!--/--> | Sex &lt;chr&gt; | Pclass &lt;int&gt; |\n",
       "|---|---|---|\n",
       "| 1 | female | 1 |\n",
       "| 3 | female | 2 |\n",
       "\n"
      ],
      "text/plain": [
       "  Sex    Pclass\n",
       "1 female 1     \n",
       "3 female 2     "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q4c. Use the training set to group passengers by both sex and passenger class.\n",
    "#Which sex and class combinations were more likely to survive than die (i.e. >50% survival)?\n",
    "\n",
    "\n",
    "survival_rates <- aggregate(Survived ~ Sex + Pclass, data = train_set, FUN = function(x) mean(x == 1))\n",
    "\n",
    "likely_to_survive <- survival_rates[survival_rates$Survived > 0.5, c(\"Sex\", \"Pclass\")]\n",
    "\n",
    "likely_to_survive\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 10,
   "id": "0c7de890",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:48.176215Z",
     "iopub.status.busy": "2024-06-11T15:35:48.174157Z",
     "iopub.status.idle": "2024-06-11T15:35:48.202398Z",
     "shell.execute_reply": "2024-06-11T15:35:48.199477Z"
    },
    "papermill": {
     "duration": 0.043099,
     "end_time": "2024-06-11T15:35:48.206105",
     "exception": false,
     "start_time": "2024-06-11T15:35:48.163006",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "0.793296089385475"
      ],
      "text/latex": [
       "0.793296089385475"
      ],
      "text/markdown": [
       "0.793296089385475"
      ],
      "text/plain": [
       "[1] 0.793"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q4d. Predict survival using both sex and passenger class on the test set. Predict survival if the survival rate for a sex/class combination is over 0.5, otherwise predict death.\n",
    "#What is the accuracy of this sex- and class-based prediction method on the test set?\n",
    "\n",
    "\n",
    "sex_class_model <- ifelse(test_set$Sex == \"female\" & test_set$Pclass != 3, 1, 0)\n",
    "mean(sex_class_model == test_set$Survived)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 11,
   "id": "9c548037",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:48.228245Z",
     "iopub.status.busy": "2024-06-11T15:35:48.226176Z",
     "iopub.status.idle": "2024-06-11T15:35:48.335568Z",
     "shell.execute_reply": "2024-06-11T15:35:48.332885Z"
    },
    "papermill": {
     "duration": 0.12442,
     "end_time": "2024-06-11T15:35:48.339105",
     "exception": false,
     "start_time": "2024-06-11T15:35:48.214685",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Confusion Matrix and Statistics\n",
       "\n",
       "          Reference\n",
       "Prediction  0  1\n",
       "         0 96 20\n",
       "         1 14 49\n",
       "                                        \n",
       "               Accuracy : 0.81          \n",
       "                 95% CI : (0.745, 0.865)\n",
       "    No Information Rate : 0.615         \n",
       "    P-Value [Acc > NIR] : 1.35e-08      \n",
       "                                        \n",
       "                  Kappa : 0.592         \n",
       "                                        \n",
       " Mcnemar's Test P-Value : 0.391         \n",
       "                                        \n",
       "            Sensitivity : 0.873         \n",
       "            Specificity : 0.710         \n",
       "         Pos Pred Value : 0.828         \n",
       "         Neg Pred Value : 0.778         \n",
       "             Prevalence : 0.615         \n",
       "         Detection Rate : 0.536         \n",
       "   Detection Prevalence : 0.648         \n",
       "      Balanced Accuracy : 0.791         \n",
       "                                        \n",
       "       'Positive' Class : 0             \n",
       "                                        "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "Confusion Matrix and Statistics\n",
       "\n",
       "          Reference\n",
       "Prediction  0  1\n",
       "         0 98 45\n",
       "         1 12 24\n",
       "                                        \n",
       "               Accuracy : 0.682         \n",
       "                 95% CI : (0.608, 0.749)\n",
       "    No Information Rate : 0.615         \n",
       "    P-Value [Acc > NIR] : 0.0375        \n",
       "                                        \n",
       "                  Kappa : 0.262         \n",
       "                                        \n",
       " Mcnemar's Test P-Value : 2.25e-05      \n",
       "                                        \n",
       "            Sensitivity : 0.891         \n",
       "            Specificity : 0.348         \n",
       "         Pos Pred Value : 0.685         \n",
       "         Neg Pred Value : 0.667         \n",
       "             Prevalence : 0.615         \n",
       "         Detection Rate : 0.547         \n",
       "   Detection Prevalence : 0.799         \n",
       "      Balanced Accuracy : 0.619         \n",
       "                                        \n",
       "       'Positive' Class : 0             \n",
       "                                        "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "Confusion Matrix and Statistics\n",
       "\n",
       "          Reference\n",
       "Prediction   0   1\n",
       "         0 109  36\n",
       "         1   1  33\n",
       "                                       \n",
       "               Accuracy : 0.793        \n",
       "                 95% CI : (0.727, 0.85)\n",
       "    No Information Rate : 0.615        \n",
       "    P-Value [Acc > NIR] : 2.28e-07     \n",
       "                                       \n",
       "                  Kappa : 0.518        \n",
       "                                       \n",
       " Mcnemar's Test P-Value : 2.28e-08     \n",
       "                                       \n",
       "            Sensitivity : 0.991        \n",
       "            Specificity : 0.478        \n",
       "         Pos Pred Value : 0.752        \n",
       "         Neg Pred Value : 0.971        \n",
       "             Prevalence : 0.615        \n",
       "         Detection Rate : 0.609        \n",
       "   Detection Prevalence : 0.810        \n",
       "      Balanced Accuracy : 0.735        \n",
       "                                       \n",
       "       'Positive' Class : 0            \n",
       "                                       "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q5a.Use the confusionMatrix() function to create confusion matrices for the sex model, class model, and combined sex and class model. You will need to convert predictions and survival status to factors to use this function.\n",
    "#What is the \"positive\" class used to calculate confusion matrix metrics?\n",
    "#Which model has the highest sensitivity?\n",
    "#Which model has the highest specificity?\n",
    "#Which model has the highest balanced accuracy?\n",
    "\n",
    "\n",
    "confusionMatrix(data = factor(sex_model), reference = factor(test_set$Survived))\n",
    "confusionMatrix(data = factor(class_model), reference = factor(test_set$Survived))\n",
    "confusionMatrix(data = factor(sex_class_model), reference = factor(test_set$Survived))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 12,
   "id": "4c01f180",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:35:48.361916Z",
     "iopub.status.busy": "2024-06-11T15:35:48.359795Z",
     "iopub.status.idle": "2024-06-11T15:35:48.413293Z",
     "shell.execute_reply": "2024-06-11T15:35:48.410636Z"
    },
    "papermill": {
     "duration": 0.068913,
     "end_time": "2024-06-11T15:35:48.416924",
     "exception": false,
     "start_time": "2024-06-11T15:35:48.348011",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Confusion Matrix and Statistics\n",
       "\n",
       "          Reference\n",
       "Prediction  0  1\n",
       "         0 96 20\n",
       "         1 14 49\n",
       "                                        \n",
       "               Accuracy : 0.81          \n",
       "                 95% CI : (0.745, 0.865)\n",
       "    No Information Rate : 0.615         \n",
       "    P-Value [Acc > NIR] : 1.35e-08      \n",
       "                                        \n",
       "                  Kappa : 0.592         \n",
       "                                        \n",
       " Mcnemar's Test P-Value : 0.391         \n",
       "                                        \n",
       "            Sensitivity : 0.873         \n",
       "            Specificity : 0.710         \n",
       "         Pos Pred Value : 0.828         \n",
       "         Neg Pred Value : 0.778         \n",
       "             Prevalence : 0.615         \n",
       "         Detection Rate : 0.536         \n",
       "   Detection Prevalence : 0.648         \n",
       "      Balanced Accuracy : 0.791         \n",
       "                                        \n",
       "       'Positive' Class : 0             \n",
       "                                        "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "Confusion Matrix and Statistics\n",
       "\n",
       "          Reference\n",
       "Prediction  0  1\n",
       "         0 98 45\n",
       "         1 12 24\n",
       "                                        \n",
       "               Accuracy : 0.682         \n",
       "                 95% CI : (0.608, 0.749)\n",
       "    No Information Rate : 0.615         \n",
       "    P-Value [Acc > NIR] : 0.0375        \n",
       "                                        \n",
       "                  Kappa : 0.262         \n",
       "                                        \n",
       " Mcnemar's Test P-Value : 2.25e-05      \n",
       "                                        \n",
       "            Sensitivity : 0.891         \n",
       "            Specificity : 0.348         \n",
       "         Pos Pred Value : 0.685         \n",
       "         Neg Pred Value : 0.667         \n",
       "             Prevalence : 0.615         \n",
       "         Detection Rate : 0.547         \n",
       "   Detection Prevalence : 0.799         \n",
       "      Balanced Accuracy : 0.619         \n",
       "                                        \n",
       "       'Positive' Class : 0             \n",
       "                                        "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "Confusion Matrix and Statistics\n",
       "\n",
       "          Reference\n",
       "Prediction   0   1\n",
       "         0 109  36\n",
       "         1   1  33\n",
       "                                       \n",
       "               Accuracy : 0.793        \n",
       "                 95% CI : (0.727, 0.85)\n",
       "    No Information Rate : 0.615        \n",
       "    P-Value [Acc > NIR] : 2.28e-07     \n",
       "                                       \n",
       "                  Kappa : 0.518        \n",
       "                                       \n",
       " Mcnemar's Test P-Value : 2.28e-08     \n",
       "                                       \n",
       "            Sensitivity : 0.991        \n",
       "            Specificity : 0.478        \n",
       "         Pos Pred Value : 0.752        \n",
       "         Neg Pred Value : 0.971        \n",
       "             Prevalence : 0.615        \n",
       "         Detection Rate : 0.609        \n",
       "   Detection Prevalence : 0.810        \n",
       "      Balanced Accuracy : 0.735        \n",
       "                                       \n",
       "       'Positive' Class : 0            \n",
       "                                       "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q5b.What is the maximum value of balanced accuracy from Q5a?\n",
    "\n",
    "confusionMatrix(data = factor(sex_model), reference = factor(test_set$Survived))\n",
    "confusionMatrix(data = factor(class_model), reference = factor(test_set$Survived))\n",
    "confusionMatrix(data = factor(sex_class_model), reference = factor(test_set$Survived))\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "eaa41279",
   "metadata": {
    "papermill": {
     "duration": 0.009608,
     "end_time": "2024-06-11T15:35:48.435971",
     "exception": false,
     "start_time": "2024-06-11T15:35:48.426363",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kaggle": {
   "accelerator": "none",
   "dataSources": [],
   "dockerImageVersionId": 30618,
   "isGpuEnabled": false,
   "isInternetEnabled": true,
   "language": "r",
   "sourceType": "notebook"
  },
  "kernelspec": {
   "display_name": "R",
   "language": "R",
   "name": "ir"
  },
  "language_info": {
   "codemirror_mode": "r",
   "file_extension": ".r",
   "mimetype": "text/x-r-source",
   "name": "R",
   "pygments_lexer": "r",
   "version": "4.0.5"
  },
  "papermill": {
   "default_parameters": {},
   "duration": 8.774537,
   "end_time": "2024-06-11T15:35:48.573354",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2024-06-11T15:35:39.798817",
   "version": "2.5.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
