-- Script de inicialización de la base de datos PostgreSQL
-- Crea la tabla de tareas (tasku)

CREATE TABLE IF NOT EXISTS tasku (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para búsquedas por estado de completado
CREATE INDEX IF NOT EXISTS idx_tasku_completed ON tasku(completed);
