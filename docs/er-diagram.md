# ER Diagram

This document contains the Entity-Relationship Diagram for the nutrition coach bot, generated in Mermaid syntax.

```erDiagram
    profiles {
        UUID id PK
        TEXT discord_id UK "Discord User ID"
        TEXT name
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    body_compositions {
        UUID id PK
        UUID user_id FK
        REAL height
        REAL weight
        REAL muscle_mass
        REAL body_fat_percentage
        TIMESTAMP measured_at
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    body_goals {
        UUID id PK
        UUID user_id FK
        REAL target_weight
        REAL target_muscle_mass
        REAL target_body_fat_percentage
        TIMESTAMP start_date
        TIMESTAMP target_date
        BOOLEAN is_active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    nutrition_goals {
        UUID id PK
        UUID user_id FK
        INTEGER target_daily_calories
        REAL target_daily_protein
        TIMESTAMP start_date
        TIMESTAMP target_date
        BOOLEAN is_active
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    nutrition_logs {
        UUID id PK
        UUID user_id FK
        DATE date
        INTEGER total_calories
        REAL total_protein
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    meal_logs {
        UUID id PK
        UUID user_id FK
        DATE meal_date
        TEXT meal_type "e.g., breakfast, lunch"
        TEXT description "Food description"
        INTEGER total_calories
        REAL total_protein
        TEXT[] image_urls "Array of image URLs"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    conversation_logs {
        UUID id PK
        UUID user_id FK
        TEXT cog_name "Cog name (e.g., 'nutrition')"
        TEXT user_input
        TEXT bot_output
        JSONB context "Cog-specific context"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    profiles ||--o{ body_compositions : "has"
    profiles ||--o{ body_goals : "sets"
    profiles ||--o{ nutrition_goals : "sets"
    profiles ||--o{ nutrition_logs : "records"
    profiles ||--o{ meal_logs : "records"
    profiles ||--o{ conversation_logs : "has"
```
