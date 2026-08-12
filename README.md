# brickfox XmlExchange – XSD schemas

Public, canonical XML Schema Definitions (XSD) for the **brickfox XmlExchange** ERP
integration interface. These schemas define the structure of the XML documents
exchanged between an ERP system and the brickfox platform (product, order,
category and related data).

This repository is the **single source of truth** for the XmlExchange schemas.
Do not keep hand-maintained copies elsewhere — mirror this repository instead, so you
always validate against the published version. A local fallback copy is fine and in fact
recommended (see [Consuming the schemas](#consuming-the-schemas)); a copy that is only
ever updated by hand is what goes stale.

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

## Consuming the schemas

Your interfaces must not fail when GitHub is temporarily unreachable. The pattern we use
in our own services:

1. **Mirror, don't fetch per request.** Copy the set you need into a local directory and
   refresh it on a schedule — once a day is plenty, the schemas change rarely.
2. **Keep serving the last mirror** when the fetch fails, and log it. An outage must not
   turn into a failed import.
3. **Ship a bootstrap copy** for the very first start of a fresh deployment, so a cold
   mirror plus an outage cannot leave you without a schema at all.
4. **Validate against one complete set.** Never mix files from different snapshots:
   `baseProducts.xsd` is included by relative path, so a mismatched pair silently
   validates against the wrong types. Writing each refresh into its own directory and
   switching over only once it is complete is a simple way to guarantee this.
5. **Pin to `stable`**, not to `latest` or `main`.

A build- or deploy-time fetch instead of a scheduled refresh is equally fine — the point
is that no single request depends on GitHub being reachable.

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

## How these schemas get here

The schemas originate from the brickfox Core (`BFcore/brick/modules/XmlExchange/xsd/`)
and are published from its deployment pipeline:

1. A **master deploy** copies the curated schema set into `xsd/` on the `latest` branch and
   rewrites [`VERSION`](VERSION) with the originating Core commit and publish timestamp.
   The step is idempotent — it only commits when a published schema actually changed.
2. `stable` is updated **only** by a separate, manually triggered promote step, which
   fast-forwards `latest` onto `stable`. That gate is why a schema change never reaches
   pinned consumers unannounced.

So `stable` can lag `latest` by design: a change sits on `latest` until it is deliberately
released. [`VERSION`](VERSION) on each branch tells you which Core commit that branch
reflects.

A read-only drift check is provided in [`bin/check-xsd-drift.sh`](bin/check-xsd-drift.sh)
to compare this repository against a Core checkout.

## License

These schemas are published under the [MIT License](LICENSE), Copyright (c) 2011-2026
brickfox GmbH. You may copy, embed and redistribute them — including in commercial
products — as long as the copyright and license notice is retained.
