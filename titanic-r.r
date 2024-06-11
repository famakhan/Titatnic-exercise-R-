{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "689ee8e7",
   "metadata": {
    "_execution_state": "idle",
    "_uuid": "051d70d956493feee0c6d64651c6a088724dca2a",
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:53.646795Z",
     "iopub.status.busy": "2024-06-11T14:13:53.644215Z",
     "iopub.status.idle": "2024-06-11T14:13:54.904867Z",
     "shell.execute_reply": "2024-06-11T14:13:54.902853Z"
    },
    "papermill": {
     "duration": 1.270091,
     "end_time": "2024-06-11T14:13:54.908243",
     "exception": false,
     "start_time": "2024-06-11T14:13:53.638152",
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
   "id": "b2f4e81e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:54.948824Z",
     "iopub.status.busy": "2024-06-11T14:13:54.916232Z",
     "iopub.status.idle": "2024-06-11T14:13:57.371008Z",
     "shell.execute_reply": "2024-06-11T14:13:57.369112Z"
    },
    "papermill": {
     "duration": 2.4627,
     "end_time": "2024-06-11T14:13:57.373983",
     "exception": false,
     "start_time": "2024-06-11T14:13:54.911283",
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
   "id": "3390aa35",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:57.384945Z",
     "iopub.status.busy": "2024-06-11T14:13:57.383281Z",
     "iopub.status.idle": "2024-06-11T14:13:57.445449Z",
     "shell.execute_reply": "2024-06-11T14:13:57.443567Z"
    },
    "papermill": {
     "duration": 0.07078,
     "end_time": "2024-06-11T14:13:57.448115",
     "exception": false,
     "start_time": "2024-06-11T14:13:57.377335",
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
   "id": "142960c5",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:57.460114Z",
     "iopub.status.busy": "2024-06-11T14:13:57.458087Z",
     "iopub.status.idle": "2024-06-11T14:13:57.483326Z",
     "shell.execute_reply": "2024-06-11T14:13:57.481484Z"
    },
    "papermill": {
     "duration": 0.034276,
     "end_time": "2024-06-11T14:13:57.486332",
     "exception": false,
     "start_time": "2024-06-11T14:13:57.452056",
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
   "id": "e290d3d2",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:57.498300Z",
     "iopub.status.busy": "2024-06-11T14:13:57.496582Z",
     "iopub.status.idle": "2024-06-11T14:13:57.591610Z",
     "shell.execute_reply": "2024-06-11T14:13:57.589702Z"
    },
    "papermill": {
     "duration": 0.103816,
     "end_time": "2024-06-11T14:13:57.594141",
     "exception": false,
     "start_time": "2024-06-11T14:13:57.490325",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Warning message in mean.default(train_set$Survived[train_set$Sex == \"female\"], na.rm = TRUE):\n",
      "“argument is not numeric or logical: returning NA”\n",
      "Warning message in mean.default(train_set$Survived[train_set$Sex == \"male\"], na.rm = TRUE):\n",
      "“argument is not numeric or logical: returning NA”\n"
     ]
    },
    {
     "data": {
      "text/html": [
       "&lt;NA&gt;"
      ],
      "text/latex": [
       "<NA>"
      ],
      "text/markdown": [
       "&lt;NA&gt;"
      ],
      "text/plain": [
       "[1] NA"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "&lt;NA&gt;"
      ],
      "text/latex": [
       "<NA>"
      ],
      "text/markdown": [
       "&lt;NA&gt;"
      ],
      "text/plain": [
       "[1] NA"
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
       "\t<tr><td>female</td><td>1.73</td></tr>\n",
       "\t<tr><td>male  </td><td>1.19</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 2 × 2\n",
       "\\begin{tabular}{ll}\n",
       " Sex & proportion\\_survived\\\\\n",
       " <chr> & <dbl>\\\\\n",
       "\\hline\n",
       "\t female & 1.73\\\\\n",
       "\t male   & 1.19\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 2 × 2\n",
       "\n",
       "| Sex &lt;chr&gt; | proportion_survived &lt;dbl&gt; |\n",
       "|---|---|\n",
       "| female | 1.73 |\n",
       "| male   | 1.19 |\n",
       "\n"
      ],
      "text/plain": [
       "  Sex    proportion_survived\n",
       "1 female 1.73               \n",
       "2 male   1.19               "
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
    "\n",
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
   "id": "81ff6d4e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:57.606953Z",
     "iopub.status.busy": "2024-06-11T14:13:57.605335Z",
     "iopub.status.idle": "2024-06-11T14:13:57.627766Z",
     "shell.execute_reply": "2024-06-11T14:13:57.625902Z"
    },
    "papermill": {
     "duration": 0.031685,
     "end_time": "2024-06-11T14:13:57.630350",
     "exception": false,
     "start_time": "2024-06-11T14:13:57.598665",
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
   "id": "6f5555b4",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:57.643753Z",
     "iopub.status.busy": "2024-06-11T14:13:57.642061Z",
     "iopub.status.idle": "2024-06-11T14:13:57.675932Z",
     "shell.execute_reply": "2024-06-11T14:13:57.674080Z"
    },
    "papermill": {
     "duration": 0.043512,
     "end_time": "2024-06-11T14:13:57.678653",
     "exception": false,
     "start_time": "2024-06-11T14:13:57.635141",
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
   "id": "16a6ddce",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T14:13:57.693396Z",
     "iopub.status.busy": "2024-06-11T14:13:57.691712Z",
     "iopub.status.idle": "2024-06-11T14:13:57.715145Z",
     "shell.execute_reply": "2024-06-11T14:13:57.713220Z"
    },
    "papermill": {
     "duration": 0.034022,
     "end_time": "2024-06-11T14:13:57.717924",
     "exception": false,
     "start_time": "2024-06-11T14:13:57.683902",
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
   "duration": 7.812811,
   "end_time": "2024-06-11T14:13:57.846832",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2024-06-11T14:13:50.034021",
   "version": "2.5.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
