{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "74fafcb8",
   "metadata": {
    "_execution_state": "idle",
    "_uuid": "051d70d956493feee0c6d64651c6a088724dca2a",
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:22.242497Z",
     "iopub.status.busy": "2024-06-11T15:57:22.240004Z",
     "iopub.status.idle": "2024-06-11T15:57:23.443612Z",
     "shell.execute_reply": "2024-06-11T15:57:23.441808Z"
    },
    "papermill": {
     "duration": 1.214014,
     "end_time": "2024-06-11T15:57:23.446274",
     "exception": false,
     "start_time": "2024-06-11T15:57:22.232260",
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
   "id": "c3fc32a1",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:23.487782Z",
     "iopub.status.busy": "2024-06-11T15:57:23.457373Z",
     "iopub.status.idle": "2024-06-11T15:57:25.850778Z",
     "shell.execute_reply": "2024-06-11T15:57:25.848887Z"
    },
    "papermill": {
     "duration": 2.403193,
     "end_time": "2024-06-11T15:57:25.854105",
     "exception": false,
     "start_time": "2024-06-11T15:57:23.450912",
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
   "id": "05ec663b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:25.867036Z",
     "iopub.status.busy": "2024-06-11T15:57:25.865426Z",
     "iopub.status.idle": "2024-06-11T15:57:25.931316Z",
     "shell.execute_reply": "2024-06-11T15:57:25.928925Z"
    },
    "papermill": {
     "duration": 0.075761,
     "end_time": "2024-06-11T15:57:25.934430",
     "exception": false,
     "start_time": "2024-06-11T15:57:25.858669",
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
   "id": "41e17237",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:25.948729Z",
     "iopub.status.busy": "2024-06-11T15:57:25.947116Z",
     "iopub.status.idle": "2024-06-11T15:57:25.973268Z",
     "shell.execute_reply": "2024-06-11T15:57:25.970842Z"
    },
    "papermill": {
     "duration": 0.036844,
     "end_time": "2024-06-11T15:57:25.976512",
     "exception": false,
     "start_time": "2024-06-11T15:57:25.939668",
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
   "id": "04b0c770",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:25.991112Z",
     "iopub.status.busy": "2024-06-11T15:57:25.989484Z",
     "iopub.status.idle": "2024-06-11T15:57:26.079412Z",
     "shell.execute_reply": "2024-06-11T15:57:26.077533Z"
    },
    "papermill": {
     "duration": 0.100536,
     "end_time": "2024-06-11T15:57:26.082461",
     "exception": false,
     "start_time": "2024-06-11T15:57:25.981925",
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
   "id": "f708c868",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.097746Z",
     "iopub.status.busy": "2024-06-11T15:57:26.096027Z",
     "iopub.status.idle": "2024-06-11T15:57:26.119736Z",
     "shell.execute_reply": "2024-06-11T15:57:26.117808Z"
    },
    "papermill": {
     "duration": 0.034817,
     "end_time": "2024-06-11T15:57:26.122994",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.088177",
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
   "id": "17a1e2de",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.138768Z",
     "iopub.status.busy": "2024-06-11T15:57:26.137140Z",
     "iopub.status.idle": "2024-06-11T15:57:26.172329Z",
     "shell.execute_reply": "2024-06-11T15:57:26.169869Z"
    },
    "papermill": {
     "duration": 0.046405,
     "end_time": "2024-06-11T15:57:26.175483",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.129078",
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
   "id": "0b3b6d27",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.191476Z",
     "iopub.status.busy": "2024-06-11T15:57:26.189828Z",
     "iopub.status.idle": "2024-06-11T15:57:26.212900Z",
     "shell.execute_reply": "2024-06-11T15:57:26.210512Z"
    },
    "papermill": {
     "duration": 0.03444,
     "end_time": "2024-06-11T15:57:26.215955",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.181515",
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
   "id": "f1e0a7b1",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.232002Z",
     "iopub.status.busy": "2024-06-11T15:57:26.230437Z",
     "iopub.status.idle": "2024-06-11T15:57:26.265411Z",
     "shell.execute_reply": "2024-06-11T15:57:26.263015Z"
    },
    "papermill": {
     "duration": 0.046403,
     "end_time": "2024-06-11T15:57:26.268467",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.222064",
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
   "id": "614b70e0",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.285293Z",
     "iopub.status.busy": "2024-06-11T15:57:26.283577Z",
     "iopub.status.idle": "2024-06-11T15:57:26.307045Z",
     "shell.execute_reply": "2024-06-11T15:57:26.304559Z"
    },
    "papermill": {
     "duration": 0.035399,
     "end_time": "2024-06-11T15:57:26.310251",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.274852",
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
   "id": "d8af1a63",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.327219Z",
     "iopub.status.busy": "2024-06-11T15:57:26.325612Z",
     "iopub.status.idle": "2024-06-11T15:57:26.418326Z",
     "shell.execute_reply": "2024-06-11T15:57:26.416100Z"
    },
    "papermill": {
     "duration": 0.104693,
     "end_time": "2024-06-11T15:57:26.421458",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.316765",
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
   "id": "e358eaf3",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.439233Z",
     "iopub.status.busy": "2024-06-11T15:57:26.437626Z",
     "iopub.status.idle": "2024-06-11T15:57:26.482591Z",
     "shell.execute_reply": "2024-06-11T15:57:26.480233Z"
    },
    "papermill": {
     "duration": 0.057321,
     "end_time": "2024-06-11T15:57:26.485879",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.428558",
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
   "execution_count": 13,
   "id": "a508e90e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.504434Z",
     "iopub.status.busy": "2024-06-11T15:57:26.502775Z",
     "iopub.status.idle": "2024-06-11T15:57:26.539657Z",
     "shell.execute_reply": "2024-06-11T15:57:26.537884Z"
    },
    "papermill": {
     "duration": 0.049773,
     "end_time": "2024-06-11T15:57:26.542967",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.493194",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "0.849557522123894"
      ],
      "text/latex": [
       "0.849557522123894"
      ],
      "text/markdown": [
       "0.849557522123894"
      ],
      "text/plain": [
       "[1] 0.85"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "0.774703557312253"
      ],
      "text/latex": [
       "0.774703557312253"
      ],
      "text/markdown": [
       "0.774703557312253"
      ],
      "text/plain": [
       "[1] 0.775"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "0.854901960784314"
      ],
      "text/latex": [
       "0.854901960784314"
      ],
      "text/markdown": [
       "0.854901960784314"
      ],
      "text/plain": [
       "[1] 0.855"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q6. Use the F_meas() function to calculate  scores for the sex model, class model, and combined sex and class model. You will need to convert predictions to factors to use this function.\n",
    "#Which model has the highest  score?\n",
    "#What is the maximum value of the  score?\n",
    "\n",
    "        \n",
    "F_meas(data = factor(sex_model), reference = test_set$Survived)\n",
    "F_meas(data = factor(class_model), reference = test_set$Survived)\n",
    "F_meas(data = factor(sex_class_model), reference = test_set$Survived)\n",
    "      "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 14,
   "id": "6001708d",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:26.562443Z",
     "iopub.status.busy": "2024-06-11T15:57:26.560731Z",
     "iopub.status.idle": "2024-06-11T15:57:27.631101Z",
     "shell.execute_reply": "2024-06-11T15:57:27.629143Z"
    },
    "papermill": {
     "duration": 1.083223,
     "end_time": "2024-06-11T15:57:27.634086",
     "exception": false,
     "start_time": "2024-06-11T15:57:26.550863",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Warning message in train.default(x, y, weights = w, ...):\n",
      "“You are trying to do regression and your outcome only has two possible values Are you trying to do classification? If so, use a 2 level factor as your outcome column.”\n",
      "Loading required package: gam\n",
      "\n",
      "Loading required package: splines\n",
      "\n",
      "Loading required package: foreach\n",
      "\n",
      "\n",
      "Attaching package: ‘foreach’\n",
      "\n",
      "\n",
      "The following objects are masked from ‘package:purrr’:\n",
      "\n",
      "    accumulate, when\n",
      "\n",
      "\n",
      "Loaded gam 1.22-3\n",
      "\n",
      "\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“eval  512.33”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“upperlimit  264.31”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“extrapolation not allowed with blending”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“eval  512.33”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“upperlimit  264.31”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“extrapolation not allowed with blending”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“eval  512.33”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“upperlimit  264.31”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“extrapolation not allowed with blending”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“eval  512.33”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“upperlimit  264.31”\n",
      "Warning message in gam.lo(data[[\"lo(Fare, span = 0.5, degree = 1)\"]], z, w, span = 0.5, :\n",
      "“extrapolation not allowed with blending”\n"
     ]
    },
    {
     "data": {
      "text/html": [
       "0"
      ],
      "text/latex": [
       "0"
      ],
      "text/markdown": [
       "0"
      ],
      "text/plain": [
       "[1] 0"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q7. Set the seed to 1. Train a model using Loess with the caret gamLoess method using fare as the only predictor.\n",
    "#What is the accuracy on the test set for the Loess model?\n",
    "#Note: when training models for Titanic Exercises Part 2, please use the S3 method for class formula rather than the default S3 method of caret train() (see ?caret::train for details).\n",
    "\n",
    "\n",
    "set.seed(1) \n",
    "train_loess <- train(Survived ~ Fare, method = \"gamLoess\", data = train_set)\n",
    "loess_preds <- predict(train_loess, test_set)\n",
    "mean(loess_preds == test_set$Survived)\n",
    "\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 15,
   "id": "71649c5e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2024-06-11T15:57:27.657177Z",
     "iopub.status.busy": "2024-06-11T15:57:27.655623Z",
     "iopub.status.idle": "2024-06-11T15:57:28.946608Z",
     "shell.execute_reply": "2024-06-11T15:57:28.944228Z"
    },
    "papermill": {
     "duration": 1.306224,
     "end_time": "2024-06-11T15:57:28.949867",
     "exception": false,
     "start_time": "2024-06-11T15:57:27.643643",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Warning message in train.default(x, y, weights = w, ...):\n",
      "“You are trying to do regression and your outcome only has two possible values Are you trying to do classification? If so, use a 2 level factor as your outcome column.”\n"
     ]
    },
    {
     "data": {
      "text/html": [
       "0"
      ],
      "text/latex": [
       "0"
      ],
      "text/markdown": [
       "0"
      ],
      "text/plain": [
       "[1] 0"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Warning message in train.default(x, y, weights = w, ...):\n",
      "“You are trying to do regression and your outcome only has two possible values Are you trying to do classification? If so, use a 2 level factor as your outcome column.”\n"
     ]
    },
    {
     "data": {
      "text/html": [
       "0"
      ],
      "text/latex": [
       "0"
      ],
      "text/markdown": [
       "0"
      ],
      "text/plain": [
       "[1] 0"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Warning message in train.default(x, y, weights = w, ...):\n",
      "“You are trying to do regression and your outcome only has two possible values Are you trying to do classification? If so, use a 2 level factor as your outcome column.”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n",
      "Warning message in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :\n",
      "“prediction from a rank-deficient fit may be misleading”\n"
     ]
    },
    {
     "data": {
      "text/html": [
       "0"
      ],
      "text/latex": [
       "0"
      ],
      "text/markdown": [
       "0"
      ],
      "text/plain": [
       "[1] 0"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "#Q8.Set the seed to 1. Train a logistic regression model with the caret glm method using age as the only predictor.\n",
    "#What is the accuracy of your model (using age as the only predictor) on the test set ?\n",
    "#Set the seed to 1. Train a logistic regression model with the caret glm method using four predictors: sex, class, fare, and age.\n",
    "#What is the accuracy of your model (using these four predictors) on the test set?\n",
    "#Set the seed to 1. Train a logistic regression model with the caret glm method using all predictors. Ignore warnings about rank-deficient fit.\n",
    "#What is the accuracy of your model (using all predictors) on the test set ?\n",
    "\n",
    "\n",
    "set.seed(1)\n",
    "train_glm_age <- train(Survived ~ Age, method = \"glm\", data = train_set)\n",
    "glm_preds_age <- predict(train_glm_age, test_set)\n",
    "mean(glm_preds_age == test_set$Survived)\n",
    "        \n",
    "\n",
    "train_glm <- train(Survived ~ Sex + Pclass + Fare + Age, method = \"glm\", data = train_set)\n",
    "glm_preds <- predict(train_glm, test_set)\n",
    "mean(glm_preds == test_set$Survived)\n",
    "\n",
    "train_glm_all <- train(Survived ~ ., method = \"glm\", data = train_set)\n",
    "glm_all_preds <- predict(train_glm_all, test_set)\n",
    "mean(glm_all_preds == test_set$Survived)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "4f11583f",
   "metadata": {
    "papermill": {
     "duration": 0.011458,
     "end_time": "2024-06-11T15:57:28.973111",
     "exception": false,
     "start_time": "2024-06-11T15:57:28.961653",
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
   "duration": 10.277838,
   "end_time": "2024-06-11T15:57:29.106870",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2024-06-11T15:57:18.829032",
   "version": "2.5.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
