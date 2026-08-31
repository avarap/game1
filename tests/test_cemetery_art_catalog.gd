class_name TestCemeteryArtCatalog
extends RefCounted

const CATALOG_PATH := "res://art/environment/cemetery/production/data/cemetery_art_catalog.tres"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(CATALOG_PATH):
		failures.append("Cemetery art catalog should be loadable")
		return failures
	var catalog := load(CATALOG_PATH)
	var ids := {}
	for spec in catalog.specs:
		if spec.id in ids:
			failures.append("Cemetery catalog ids should be unique: %s" % spec.id)
		ids[spec.id] = true
		if spec.texture == null:
			failures.append("Catalog texture should load: %s" % spec.id)
		if spec.region.position % 32 != Vector2i.ZERO or spec.region.size % 32 != Vector2i.ZERO:
			failures.append("Catalog region should follow 32 px grid: %s" % spec.id)
		if spec.pivot_px % 8 != Vector2i.ZERO or spec.footprint_px % 8 != Vector2i.ZERO:
			failures.append("Catalog pivot and footprint should align to 8 px: %s" % spec.id)
	return failures
