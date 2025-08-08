# Implementación de Estadísticas del Dashboard

Este documento describe cómo se han implementado las estadísticas del dashboard para conectar con datos reales de la base de datos.

## Estructura de la Base de Datos

### Tablas Existentes Utilizadas

1. **enrollments** - Matriculaciones de estudiantes
2. **enrollment_attendances** - Asistencias de estudiantes
3. **enrollment_observations** - Observaciones de estudiantes
4. **students** - Información de estudiantes
5. **grades** - Grados académicos
6. **academic_periods** - Períodos académicos

### Nuevas Tablas y Funciones

#### Tabla: academic_grades
```sql
CREATE TABLE IF NOT EXISTS academic_grades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    subject VARCHAR(100) NOT NULL,
    grade DECIMAL(3,2) NOT NULL CHECK (grade >= 0 AND grade <= 10),
    period VARCHAR(50) NOT NULL, -- 'bimestre1', 'bimestre2', etc.
    academic_year_id UUID REFERENCES academic_periods(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);
```

#### Funciones de Base de Datos
- `calculate_attendance_percentage()` - Calcula el porcentaje de asistencia
- `calculate_academic_average()` - Calcula el promedio académico
- `count_pending_tasks()` - Cuenta tareas pendientes
- `calculate_participation_percentage()` - Calcula el porcentaje de participación

## Archivos Creados/Modificados

### Nuevos Archivos

1. **lib/domain/dashboard/models/dashboard_stats.dart**
   - Modelo para representar las estadísticas del dashboard
   - Incluye métodos para formatear los valores para mostrar

2. **lib/domain/dashboard/services/dashboard_stats_service.dart**
   - Servicio para calcular estadísticas usando funciones de la BD
   - Incluye fallbacks para cálculos manuales si las funciones no existen

3. **lib/domain/dashboard/usecases/get_dashboard_stats_usecase.dart**
   - Caso de uso para obtener las estadísticas del dashboard

4. **database_schema.sql**
   - Script SQL para crear las tablas y funciones necesarias

### Archivos Modificados

1. **lib/screens/dashboard/components/stat_card.dart**
   - Agregado soporte para estado de carga
   - Agregado callback para tap

2. **lib/screens/dashboard_screen.dart**
   - Integrado el servicio de estadísticas
   - Las tarjetas ahora muestran datos reales con indicadores de carga

## Cómo Implementar

### Paso 1: Ejecutar el Script SQL

1. Ve a tu panel de Supabase
2. Abre el SQL Editor
3. Copia y pega el contenido de `database_schema.sql`
4. Ejecuta el script

### Paso 2: Verificar la Implementación

1. Ejecuta la aplicación
2. Ve al dashboard
3. Las estadísticas deberían cargar automáticamente
4. Si no hay datos, verás valores por defecto

### Paso 3: Insertar Datos de Prueba (Opcional)

Para probar las estadísticas, puedes insertar algunos datos de ejemplo:

```sql
-- Insertar calificaciones de ejemplo
INSERT INTO academic_grades (enrollment_id, subject, grade, period, academic_year_id) VALUES
('tu-enrollment-id', 'Matemáticas', 8.5, 'bimestre1', 'tu-academic-year-id'),
('tu-enrollment-id', 'Lenguaje', 9.0, 'bimestre1', 'tu-academic-year-id'),
('tu-enrollment-id', 'Ciencias', 8.0, 'bimestre1', 'tu-academic-year-id');

-- Actualizar estado de algunas observaciones
UPDATE enrollment_observations 
SET status = 'resolved' 
WHERE id IN (SELECT id FROM enrollment_observations LIMIT 5);
```

## Cálculos Implementados

### 1. Asistencia (95%)
- **Fuente**: Tabla `enrollment_attendances`
- **Cálculo**: (Días presentes / Total días) * 100
- **Función BD**: `calculate_attendance_percentage()`

### 2. Promedio (8.5)
- **Fuente**: Tabla `academic_grades` (nueva)
- **Cálculo**: Promedio de todas las calificaciones
- **Función BD**: `calculate_academic_average()`
- **Fallback**: Cálculo simulado basado en observaciones positivas

### 3. Tareas Pendientes (3)
- **Fuente**: Tabla `enrollment_observations`
- **Cálculo**: Conteo de observaciones con status = 'pending'
- **Función BD**: `count_pending_tasks()`

### 4. Participación (85%)
- **Fuente**: Tabla `enrollment_observations`
- **Cálculo**: (Observaciones positivas / Total observaciones) * 100
- **Función BD**: `calculate_participation_percentage()`

## Características

### ✅ Implementado
- Conexión con datos reales de la base de datos
- Indicadores de carga en las tarjetas
- Fallbacks para cálculos manuales
- Funciones optimizadas en la base de datos
- Manejo de errores robusto

### 🔄 Funcionalidades Adicionales Sugeridas
- Filtros por período (semanal, mensual, anual)
- Gráficos de tendencias
- Comparación con períodos anteriores
- Notificaciones de cambios significativos
- Exportación de reportes

## Troubleshooting

### Error: "Function does not exist"
- Verifica que hayas ejecutado el script SQL completo
- Las funciones se crean automáticamente con fallbacks

### Error: "No data available"
- Verifica que existan registros en las tablas
- Los valores por defecto se muestran cuando no hay datos

### Error: "Permission denied"
- Verifica las políticas RLS (Row Level Security) en Supabase
- Asegúrate de que el usuario tenga permisos para leer las tablas

## Próximos Pasos

1. **Datos de Calificaciones**: Implementar la captura de calificaciones académicas
2. **Métricas Avanzadas**: Agregar más indicadores como comportamiento, progreso, etc.
3. **Filtros Temporales**: Permitir ver estadísticas por diferentes períodos
4. **Comparativas**: Mostrar comparaciones con períodos anteriores
5. **Alertas**: Notificar cuando los valores estén por debajo de umbrales críticos
