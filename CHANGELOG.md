# Changelog

All notable changes to the published XmlExchange schemas are recorded here.
This project does not use version numbers; changes are tracked by date and by the
originating brickfox Core commit.

Publishing itself is automated (see the README): a Core master deploy writes to `latest`,
a manual promote step moves `latest` onto `stable`. The authoritative per-change record is
therefore the commit history of the channel branch together with [`VERSION`](VERSION);
this file summarises what changed for readers.

## On `latest`, not yet promoted to `stable`

### Core `711a2c8d` (2026-08-10)

- `manufacturers.xsd`: `Number` accepts an empty value again. It used to be `xs:integer`,
  which rejected manufacturers without a number even though the field is optional in the
  platform. It is now a union of "empty string" and `xs:integer`.

## Promoted to `stable`

### Core `59f02842` (2026-07-27)

- `manufacturers.xsd`: new optional `State` element on the manufacturer and responsible
  person addresses.
- `orderstatus.xsd`: new optional `DeliveryBillId` element.

Both fields are optional, so documents built against the previous schemas stay valid.

### Initial import — Core `9f29eed5e1` (2026-07-10)

Initial publication of the externally relevant XmlExchange schemas (UCHBF-1944).

Published (13):
`baseProducts`, `products`, `productsUpdate`, `productDelete`, `productsAssignments`,
`bundles`, `shopProductUpdate`, `articleNotDelete`, `categories`, `brands`,
`manufacturers`, `orders`, `orderstatus`.

Intentionally **not** published (internal):
`orders_sequenced` (internal order variant), `productsReports` (reporting).
