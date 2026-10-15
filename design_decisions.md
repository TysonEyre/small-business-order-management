# Database design decisions

- **Identity primary keys:** Use surrogate keys for entities, including individual order lines.
- **Order items:** Multiple lines may reference the same product in one order at different historical unit prices.
- **Historical prices:** `order_items.UnitPrice` is the price at purchase; `products.CurrentPrice` is the current catalog price.
- **Order totals:** Compute `SUM(Quantity * UnitPrice)` instead of storing a redundant order total. This is line-item value, not necessarily amount paid.
- **Product retention:** `IsActive` allows a product to be retired without removing historical references.
- **Shipping address:** Keep a snapshot on each order rather than relying on a customer's current address.
- **Status lookup and history:** `orders.OrderStatusID` stores the current status, while `order_status_history` stores events. A trigger to synchronize future status changes is planned but **not implemented**.
- **Deletion behavior:** Orders restrict customer and sales rep deletion; order items cascade on order deletion; history restricts order deletion. Because history is seeded for every order, order deletion will generally be blocked until history is addressed. This is intentional for audit retention but may warrant redesign later.
- **Seed data:** Fictional examples only. The supplied four order inserts and order-item IDs were inconsistent, so the seed script maps item groups to four inserted orders by sample order number rather than assuming specific generated IDs.
- **SKU note:** The original `MON-001` SKU is associated with `Keyboard`, which may be a naming mistake; it is retained for now and should be reviewed.
- **Time zone:** The original date-time strings had no explicit time zone. Seed values use UTC (`+00`) for reproducibility; this may differ from the original Supabase session's interpretation.
