namespace scala modeldb
namespace java modeldb
namespace py modeldb

struct Project {
  1: i32 id = -1,
  2: string name,
  3: string author,
  4: string description
}

struct ExperimentRun {
  1: i32 id = -1,
  2: i32 projectId,
  3: string description
}

struct DataFrameColumn {
  1: string name,
  2: string type
}

struct DataFrame {
  1: i32 id = -1, // when unknown
  2: list<DataFrameColumn> schema,
  3: i32 numRows,
  4: string tag = ""
}

struct HyperParameter {
  1: string name,
  2: string value,
  3: string type,
  4: double min,
  5: double max
}

struct ProjectEvent {
  1: Project project
}

struct ProjectEventResponse {
  1: i32 projectId
}

struct ExperimentRunEvent {
  1: ExperimentRun experimentrun
}

struct ExperimentRunEventResponse {
  1: i32 experimentRunId
}

// update this to be model spec?
// would make sense because it won't be
// specific to the ML env
struct TransformerSpec {
  1: i32 id = -1,
  2: string transformerType,
  3: list<string> features,
  4: list<HyperParameter> hyperparameters,
  5: string tag = ""
}

// Simplified for now. Only LinReg, LogReg
struct Transformer {
  1: i32 id = -1,
  2: list<double> weights,
  3: string transformerType,
  4: string tag =""
}

// this needs to be updated to resemble
// type, params, features
struct FitEvent {
  1: DataFrame df,
  2: TransformerSpec spec,
  3: Transformer model,
  4: list<string> featureColumns,
  5: list<string> predictionColumns,
  6: list<string> labelColumns,
  7: i32 projectId,
  8: i32 experimentRunId
}

struct FitEventResponse {
  1: i32 dfId,
  2: i32 specId,
  3: i32 modelId,
  4: i32 eventId,
  5: i32 fitEventId
}

struct MetricEvent {
  1: DataFrame df,
  2: Transformer model,
  3: string metricType,
  4: double metricValue,
  5: string labelCol,
  6: string predictionCol,
  7: i32 projectId,
  8: i32 experimentRunId
}

struct MetricEventResponse {
  1: i32 modelId,
  2: i32 dfId,
  3: i32 eventId,
  4: i32 metricEventId
}

struct TransformEvent {
  1: DataFrame oldDataFrame,
  2: DataFrame newDataFrame,
  3: Transformer transformer
  4: list<string> inputColumns,
  5: list<string> outputColumns,
  6: i32 projectId,
  7: i32 experimentRunId
}

struct TransformEventResponse {
  1: i32 oldDataFrameId,
  2: i32 newDataFrameId,
  3: i32 transformerId,
  4: i32 eventId,
  5: string filepath
}

struct RandomSplitEvent {
  1: DataFrame oldDataFrame,
  2: list<double> weights,
  3: i64 seed,
  4: list<DataFrame> splitDataFrames,
  5: i32 projectId,
  6: i32 experimentRunId
}

struct RandomSplitEventResponse {
  1: i32 oldDataFrameId,
  2: list<i32> splitIds,
  3: i32 splitEventId
}

struct CrossValidationFold {
  1: Transformer model,
  2: DataFrame validationDf,
  3: DataFrame trainingDf,
  4: double score
}

struct CrossValidationFoldResponse {
  1: i32 modelId,
  2: i32 validationId,
  3: i32 trainingId
}

struct CrossValidationEvent {
  1: DataFrame df,
  2: TransformerSpec spec,
  3: i64 seed,
  4: string evaluator,
  5: list<string> labelColumns,
  6: list<string> predictionColumns,
  7: list<string> featureColumns,
  // Note that we don't need to store numFolds, because we can infer that from from the length of this list.
  8: list<CrossValidationFold> folds,
  9: i32 projectId,
  10: i32 experimentRunId
}

struct CrossValidationEventResponse {
  1: i32 dfId,
  2: i32 specId,
  3: i32 eventId,
  4: list<CrossValidationFoldResponse> foldResponses,
  5: i32 crossValidationEventId
}

struct GridSearchCrossValidationEvent {
  1: i32 numFolds,
  2: FitEvent bestFit,
  3: list<CrossValidationEvent> crossValidations,
  4: i32 projectId,
  5: i32 experimentRunId
}

struct GridSearchCrossValidationEventResponse {
  1: i32 gscveId,
  2: i32 eventId,
  3: FitEventResponse fitEventResponse,
  4: list<CrossValidationEventResponse> crossValidationEventResponses
}

struct PipelineTransformStage {
  1: i32 stageNumber,
  2: TransformEvent te
}

struct PipelineFitStage {
  1: i32 stageNumber,
  2: FitEvent fe
}

struct PipelineEvent {
  1: FitEvent pipelineFit,
  2: list<PipelineTransformStage> transformStages,
  3: list<PipelineFitStage> fitStages,
  4: i32 projectId,
  5: i32 experimentRunId
}

struct PipelineEventResponse {
  1: FitEventResponse pipelineFitResponse,
  2: list<TransformEventResponse> transformStagesResponses,
  3: list<FitEventResponse> fitStagesResponses
}

struct AnnotationFragment {
  1: string type, // Must be "dataframe", "spec", "transformer", or "message".
  2: DataFrame df, // Fill this in if type = "dataframe".
  3: TransformerSpec spec, // Fill this in if type = "spec".
  4: Transformer transformer, // Fill this in if type = "transformer".
  5: string message // Fill this in if type = "message".
}

struct AnnotationFragmentResponse {
  1: string type,
  2: i32 id // The ID of the DataFrame, Transformer, or TransformerSpec. Null if type = "message".
}

struct AnnotationEvent {
  1: list<AnnotationFragment> fragments,
  2: i32 projectId,
  3: i32 experimentRunId
}

struct AnnotationEventResponse {
  1: i32 annotationId,
  2: list<AnnotationFragmentResponse> fragmentResponses
}


struct DataFrameAncestry {
  1: bool dataframeExists,
  2: list<DataFrame> ancestors
}


service ModelDBService {
  // This is just a test method to test connection to the server
  i32 testConnection(), // 0 if success, -1 failure

  string pathForTransformer(1: i32 transformerId),

  FitEventResponse storeFitEvent(1:FitEvent fe),

  MetricEventResponse storeMetricEvent(1:MetricEvent me),

  TransformEventResponse storeTransformEvent(1:TransformEvent te),

  RandomSplitEventResponse storeRandomSplitEvent(1:RandomSplitEvent rse),

  PipelineEventResponse storePipelineEvent(1: PipelineEvent pipelineEvent),

  CrossValidationEventResponse storeCrossValidationEvent(1: CrossValidationEvent cve),

  GridSearchCrossValidationEventResponse storeGridSearchCrossValidationEvent(1: GridSearchCrossValidationEvent gscve),

  AnnotationEventResponse storeAnnotationEvent(1: AnnotationEvent ae),

  ProjectEventResponse storeProjectEvent(1: ProjectEvent pr),

  ExperimentRunEventResponse storeExperimentRunEvent(1: ExperimentRunEvent er),

  DataFrameAncestry getDataFrameAncestry(1: i32 dataFrameId)
}
