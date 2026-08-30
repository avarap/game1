class_name StorageNetwork
extends RefCounted

var providers: Array[StorageProvider] = []

func add_provider(provider: StorageProvider) -> void:
    if provider == null or not provider.is_valid():
        return
    providers.append(provider)

func has_item(item_id: StringName, amount: int = 1) -> bool:
    if amount <= 0:
        return true
    return get_available_amount(item_id) >= amount

func get_available_amount(item_id: StringName) -> int:
    var total: int = 0
    for provider in providers:
        total += provider.get_available_amount(item_id)
    return total

func consume(item_id: StringName, amount: int) -> int:
    if amount <= 0:
        return 0
    if not has_item(item_id, amount):
        return 0

    var remaining: int = amount
    for provider in providers:
        var removed: int = provider.consume(item_id, remaining)
        remaining -= removed
        if remaining == 0:
            break
    return amount - remaining

func deposit(item: ItemData, amount: int) -> int:
    if amount <= 0:
        return 0
    var remaining: int = amount
    for provider in providers:
        remaining = provider.deposit(item, remaining)
        if remaining == 0:
            break
    return remaining

func find_sources(item_id: StringName) -> Array[StorageProvider]:
    var sources: Array[StorageProvider] = []
    for provider in providers:
        if provider.get_available_amount(item_id) > 0:
            sources.append(provider)
    return sources

func clone_network() -> StorageNetwork:
    var copy := StorageNetwork.new()
    for provider in providers:
        copy.add_provider(provider.clone_provider())
    return copy

func apply_from(source: StorageNetwork) -> bool:
    if source == null or source.providers.size() != providers.size():
        return false
    for index in range(providers.size()):
        if providers[index].provider_id != source.providers[index].provider_id:
            return false
    for index in range(providers.size()):
        providers[index].apply_from(source.providers[index])
    return true
