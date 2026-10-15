# Small Business Order Management Database

## Project Overview

A relational database project designed to model and analyze the sales operations of a fictional small business.

The project demonstrates database design, data integrity, SQL development, transaction management, and business analytics using PostgreSQL hosted on Supabase.

## Technologies

- PostgreSQL
- Supabase
- SQL
- GitHub

## Database Design

The database includes the following tables:

- `customers` — Customer information
- `products` — Product catalog and pricing
- `sales_reps` — Sales representatives
- `orders` — Order headers and customer relationships
- `order_items` — Individual products and quantities within orders
- `order_statuses` — Valid order lifecycle statuses
- `order_status_history` — Historical status changes

## Key Design Decisions

- Use primary and foreign keys to enforce referential integrity.
- Preserve historical selling prices in `order_items`.
- Calculate order totals from line-item quantities and unit prices.
- Retain discontinued products using an active/inactive flag.
- Separate current order status from historical status events.
- Use appropriate deletion restrictions to protect transactional history.

## Project Roadmap

- [x] Design initial relational schema
- [x] Implement primary keys, foreign keys, and constraints
- [x] Insert initial sample data
- [x] Write basic analytical queries
- [x] Create order status history table
- [ ] Implement automated status history tracking
- [ ] Develop advanced SQL analysis
- [ ] Create database views for reporting
- [ ] Build an analytical dashboard
- [ ] Document findings and design decisions

## Data Disclaimer

All customer, product, and transaction data used in this project is fictional and intended for educational and portfolio purposes.
