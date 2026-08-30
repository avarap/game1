class_name ProductionQueue
extends RefCounted

const RESULT_IDLE: StringName = &"idle"
const RESULT_QUEUED: StringName = &"queued"
const RESULT_PROCESSING: StringName = &"processing"
const RESULT_COMPLETED: StringName = &"completed"
const RESULT_OUTPUT_BLOCKED: StringName = &"output_blocked"
const RESULT_INVALID_RECIPE: StringName = CraftingService.RESULT_INVALID_RECIPE
const RESULT_WRONG_STATION: StringName = CraftingService.RESULT_WRONG_STATION
const RESULT_MISSING_INPUTS: StringName = CraftingService.RESULT_MISSING_INPUTS

var jobs: Array[ProductionJob] = []

func enqueue(recipe: RecipeData, station_id: StringName, storage: StorageNetwork) -> StringName:
    if recipe == null or storage == null or not recipe.is_valid() or recipe.duration_seconds <= 0.0:
        return RESULT_INVALID_RECIPE
    if recipe.station != station_id:
        return RESULT_WRONG_STATION
    for ingredient in recipe.inputs:
        if not storage.has_item(ingredient.item.id, ingredient.amount):
            return RESULT_MISSING_INPUTS

    var simulated := storage.clone_network()
    for ingredient in recipe.inputs:
        simulated.consume(ingredient.item.id, ingredient.amount)
    if not storage.apply_from(simulated):
        return RESULT_INVALID_RECIPE

    jobs.append(ProductionJob.new(recipe))
    return RESULT_QUEUED

func advance(delta: float, storage: StorageNetwork) -> StringName:
    if jobs.is_empty():
        return RESULT_IDLE
    if storage == null:
        return RESULT_INVALID_RECIPE

    var job: ProductionJob = jobs[0]
    if job.state == ProductionJob.STATE_QUEUED:
        job.state = ProductionJob.STATE_PROCESSING

    if job.state != ProductionJob.STATE_AWAITING_OUTPUT:
        job.elapsed_seconds += maxf(delta, 0.0)
        if not job.is_ready():
            return RESULT_PROCESSING

    var simulated := storage.clone_network()
    for ingredient in job.recipe.outputs:
        var remainder: int = simulated.deposit(ingredient.item, ingredient.amount)
        if remainder > 0:
            job.state = ProductionJob.STATE_AWAITING_OUTPUT
            return RESULT_OUTPUT_BLOCKED

    if not storage.apply_from(simulated):
        return RESULT_INVALID_RECIPE

    job.state = ProductionJob.STATE_COMPLETED
    jobs.remove_at(0)
    return RESULT_COMPLETED

func is_empty() -> bool:
    return jobs.is_empty()

func size() -> int:
    return jobs.size()

func current_job() -> ProductionJob:
    if jobs.is_empty():
        return null
    return jobs[0]
