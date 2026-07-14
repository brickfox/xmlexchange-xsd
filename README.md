# brickfox XmlExchange – XSD schemas

Public, canonical XML Schema Definitions (XSD) for the **brickfox XmlExchange** ERP
integration interface. These schemas define the structure of the XML documents
exchanged between an ERP system and the brickfox platform (product, order,
category and related data).

This repository is the **single source of truth** for the XmlExchange schemas.
Do not embed copies of these XSDs elsewhere — reference this repository instead so
you always validate against the current, published version.

## Channels (versioning)

Instead of version numbers, the schemas are published on named branches you can pin to:

| Branch   | Meaning                                                                 |
|----------|-------------------------------------------------------------------------|
| `stable` | Recommended for integrators. Pin your tooling here.                     |
| `latest` | Newest published state (may contain changes not yet promoted to stable).|

Raw URL pattern:

```
https://raw.githubusercontent.com/brickfox/xmlexchange-xsd/stable/xsd/<schema>.xsd
```

> **Availability tip:** fetch and **cache** the schemas at build/deploy time and keep a
> local fallback copy. Do not fetch them per request at runtime — your interfaces must
> not fail if GitHub is temporarily unreachable.

## Schemas

All schemas live under [`xsd/`](xsd/). `baseProducts.xsd` is a shared type library that
is `xs:include`d by the product schemas — it is not used standalone but must always be
available alongside them.

| Schema                    | Root element        | Purpose                                                        |
|---------------------------|---------------------|----------------------------------------------------------------|
| `products.xsd`            | `Products`          | Full product import                                            |
| `productsUpdate.xsd`      | `Products`          | Partial product update                                         |
| `productDelete.xsd`       | `Products`          | Product deletion                                               |
| `productsAssignments.xsd` | `Products`          | Product assignments (e.g. category / channel assignments)      |
| `baseProducts.xsd`        | *(type library)*    | Shared product types, included by the product schemas          |
| `bundles.xsd`             | `Products`          | Product bundles                                                |
| `shopProductUpdate.xsd`   | `ShopProductsUpdate`| Shop-specific product updates                                  |
| `articleNotDelete.xsd`    | `Products`          | Articles to be excluded from deletion                          |
| `categories.xsd`          | `Categories`        | Category import                                                |
| `brands.xsd`              | `Manufacturers`     | Brand import                                                   |
| `manufacturers.xsd`       | `Manufacturers`     | Manufacturer import                                            |
| `orders.xsd`              | `Orders`            | Order export                                                   |
| `orderstatus.xsd`         | `Orders`            | Order status exchange                                          |

> Import/export direction and the exact interface paths are documented authoritatively in
> Confluence — see below. If this table and Confluence disagree, Confluence wins until this
> README is corrected.

## Include dependencies

Only one cross-schema dependency exists:

```
products.xsd, productsUpdate.xsd, productDelete.xsd, bundles.xsd
    └── xs:include  baseProducts.xsd
```

When you copy or vendor a product schema, always take `baseProducts.xsd` with it,
otherwise the include cannot be resolved.

## Documentation

Interface documentation lives in Confluence:
**"Import von Produkten via XmlExchange"** — page id `625639426`.

## Updating these schemas

The schemas originate from the brickfox Core
(`BFcore/brick/modules/XmlExchange/xsd/`). This repository is **not** auto-synced from a
deployment pipeline; it is updated deliberately. When a schema changes in Core:

1. Copy the changed file(s) into `xsd/`.
2. Update [`VERSION`](VERSION) with the originating Core commit/date.
3. Add a `CHANGELOG.md` entry.
4. Commit to `latest`; promote to `stable` once validated with integrators.

A read-only drift check is provided in [`bin/check-xsd-drift.sh`](bin/check-xsd-drift.sh)
to compare this repository against a Core checkout.
