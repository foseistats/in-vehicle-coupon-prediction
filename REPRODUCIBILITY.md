# Reproducibility notes

## Verified during preparation

- All root R scripts parse successfully.
- The supplied original data has 12,684 rows and 26 columns.
- Training and test files have 8,878 and 3,806 rows, respectively, with 83 numerical predictors and a final `Y` column. They have matching column names and no missing values.
- Training labels contain 3,853 `no` and 5,025 `yes` outcomes; test labels contain 1,621 `no` and 2,185 `yes` outcomes.
- `Rscript --vanilla run.R` successfully refits a classification tree at the original fixed complexity parameter and exports results and session information. Its test confusion matrix (1,042 true no, 547 predicted no/observed yes, 579 predicted yes/observed no, and 1,638 true yes) matches the report; test accuracy is approximately 70.415%.
- No full tuning run or independent reproduction of all eight historical classifier results was performed. Several full-pipeline dependencies are absent in the preparation environment.

## Portability edits

The root `_targets.R` has only its two absolute data paths changed to `train_set1.csv` and `test_set1.csv`. The root `preprocessing.R` reads `initialdata.csv` instead of the original absolute `coupon.csv` path. Their original contents are retained in `original-code/`. Other supplied code is unchanged.

The added `run.R` uses the supplied split and the fixed `cp = 0.0012` from the pipeline. It records a current-environment refit, not a replay of cached models or the hyperparameter search.

## Data and preprocessing

`preprocesseddata.csv` has an exported row-index column in addition to the 83 predictors and response; the split files omit that index. Do not feed the indexed CSV directly into code that selects predictors and response by fixed column positions.

The original preprocessing imputes missing values before splitting the data. Imputation therefore uses information from the whole dataset rather than just training folds. The random imputation has no fixed seed before it runs; `set.seed(42)` occurs only at the later split step. A fresh preprocessing run is not guaranteed to recreate the supplied transformed values. It also does not export its train/test objects to the filenames expected by `_targets.R`. Use the included splits for the quick run.

The original variable conversions and encoding should be reviewed before treating preprocessing as a general-purpose pipeline on a newer R environment. A future methodological revision could estimate all preprocessing within training folds and then apply it to held-out data. This package does not silently change the original coursework design.

## Modeling and evaluation limitations

- The LDA targets are commented out, but `evaluation.R` still calls them. That section also refers to session objects `Y.train`/`Y.test` and has an `as.factort` typo. The included historical `ldatp.csv` supports the later agreement section, but does not restore the missing LDA fitting branch.
- `evaluation.R` is an interactive notebook-style script, not a validated end-to-end entry point. Its final `kable()` call requires `knitr` to be attached or qualified.
- Some tuning helpers standardize predictors through `caret`, while their separately coded final fits do not consistently apply the same preprocessing. Fixed final hyperparameters also do not automatically depend on the tuning results. Review these choices before claiming that a fresh full run exactly repeats the report's comparison.
- KNN receives the raw CSV response column in the original targets, while other branches explicitly factor it. This may need adjustment with current R/caret versions. The neural-network grid uses noninteger hidden-unit sizes, another setting to review for compatibility.
- Randomized model fitting and resampling are not controlled by a documented complete historical seed/version specification. Exact historical metrics are not guaranteed across software environments.
- The report's classification-tree prose disagrees with its confusion matrices. README accuracies use tabulated test results consistently; they are reported results, not independently rerun ensemble evaluations.

## Excluded material

The attached working folder contains large `_targets/` model caches, including objects exceeding GitHub's ordinary per-file size limit, session history, IDE state, an HTML pipeline export, package source archives, and alternative working files. These were not copied into this publication package. The original files remain in place. Selected PNG figures and the historical LDA predictions were copied from the working folder; the report, principal source, and main data files came from `projsubmission/`.

The full pipeline and quick runner may create local `_targets/` and `outputs/` folders. These are ignored for source publication.
