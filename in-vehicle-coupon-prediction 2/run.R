# Quick verification of the report's fixed-cp classification tree.
# This does not rerun hyperparameter search or all eight classifiers.
main <- function() {
  if (!requireNamespace("rpart", quietly = TRUE)) stop("Install rpart first.")
  train <- read.csv("train_set1.csv")
  test <- read.csv("test_set1.csv")
  stopifnot(nrow(train) == 8878L, nrow(test) == 3806L,
            ncol(train) == 84L, identical(names(train), names(test)),
            tail(names(train), 1) == "Y", !anyNA(train), !anyNA(test))
  predictors <- setdiff(names(train), "Y")
  stopifnot(all(vapply(train[predictors], is.numeric, logical(1))),
            all(vapply(test[predictors], is.numeric, logical(1))))
  train$Y <- factor(train$Y, levels = c("no", "yes"))
  test$Y <- factor(test$Y, levels = c("no", "yes"))
  stopifnot(!anyNA(train$Y), !anyNA(test$Y))
  set.seed(42)
  fit <- rpart::rpart(Y ~ ., data = train, method = "class",
                     control = rpart::rpart.control(cp = 0.0012))
  train_pred <- predict(fit, newdata = train[predictors], type = "class")
  test_pred <- predict(fit, newdata = test[predictors], type = "class")
  dir.create("outputs", showWarnings = FALSE)
  metrics <- data.frame(model = "Fixed-cp classification tree",
                        split = c("train", "test"),
                        accuracy = c(mean(train_pred == train$Y), mean(test_pred == test$Y)))
  write.csv(metrics, "outputs/tree-metrics.csv", row.names = FALSE)
  write.csv(data.frame(observed = test$Y, predicted = test_pred),
            "outputs/tree-test-predictions.csv", row.names = FALSE)
  capture.output({
    cat("Current-environment refit, not the full original model comparison.\n")
    print(metrics)
    cat("\nTest confusion matrix\n")
    print(table(predicted = test_pred, observed = test$Y))
  }, file = "outputs/tree-summary.txt")
  capture.output(sessionInfo(), file = "outputs/session-info.txt")
  print(metrics)
}
main()
