# FiveM Basic Inventory System

A simple but functional inventory system for FiveM servers, built from scratch without frameworks. Includes money management, item purchasing, item usage, and a basic NUI interface — with full persistence via MySQL.

## Features

- Per-player money system
- Item purchasing via command
- Item usage via command or UI click
- Stackable and non-stackable items
- Basic NUI inventory interface (open with `I`)
- MySQL persistence on connect/disconnect

## Dependencies

- [oxmysql](https://github.com/overextended/oxmysql)
- MariaDB or MySQL

## Installation

1. Clone or download this resource into your `resources` folder
2. Import the database table by running `install.sql` in your database manager
3. Add the MySQL connection string to your `server.cfg`:
   ```
   set mysql_connection_string "mysql://root:yourpassword@localhost/yourdatabase"
   ```
4. Add the following to your `server.cfg`:
   ```
   ensure oxmysql
   ensure fivem-inventory
   ```
5. Start your server

## Commands

| Command | Description |
|--------|-------------|
| `/comprar [item]` | Purchase an item |
| `/usar [item]` | Use an item by name |
| `I` | Open / close the inventory UI |

## Available Items

| Item | Price | Type | Stackable |
|------|-------|------|-----------|
| `ak47` | $2500 | Weapon | No |
| `drug` | $350 | Consumable | Yes (max 5) |

## Notes

- This system is built without any framework (no ESX, no QBCore)
- All game logic is validated server-side
- Players start with $50,000 on first join
