# System Design & Business Rules Document (PRD): PWA de Reportes Ciudadanos

## 1. Stack Tecnológico y Arquitectura Base
* **Framework:** Ruby on Rails 8 (API + Vistas integradas para la PWA).
* **Base de Datos:** PostgreSQL (recomendado usar PostGIS para consultas espaciales futuras).
* **Background Jobs:** Solid Queue (nativo de Rails 8).
* **WebSockets/Real-time:** Solid Cable (nativo de Rails 8).
* **Almacenamiento de Archivos:** Active Storage (para fotos y evidencias).
* **Frontend:** PWA nativa de Rails 8 (manifest, service workers) + Hotwire (Turbo/Stimulus) para interactividad sin SPAs complejas.
* **Notificaciones:** Web Push API manejada a través de Service Workers y background jobs.

## 2. Actores y Sistema de Roles (RBAC)
El sistema opera bajo un modelo de jerarquía de árbol continuo (Adjacency List) para los funcionarios, un rol aislado para ciudadanos y un rol técnico superior.

* **SystemAdmin (Super Admin):** Mantenimiento técnico. Puede impersonar usuarios, forzar transiciones de estado, editar el polígono de geofencing y gestionar al Presidente Municipal. Sus acciones destructivas o forzadas se guardan en un `SystemAuditLog`.
* **Mayor (Presidente Municipal):** Nodo raíz del gobierno. Visibilidad global de todos los reportes y métricas. Puede crear usuarios de Nivel 1 (Directores).
* **Official (Funcionario):** Nodos intermedios/hojas. Tienen un `manager_id` referenciando a su superior. Solo ven y actúan sobre reportes de su rama hacia abajo. Pueden crear usuarios subordinados.
* **Citizen (Ciudadano):** Usuario base. Solo crea reportes y visualiza el estado de los propios.

## 3. Reglas de Negocio Core (Módulo de Reportes)

### 3.1 Creación y Validación
* **Ubicación Estricta:** Un reporte DEBE tener coordenadas (`latitude`, `longitude`) OR una descripción en texto (`location_description`). La ausencia de ambos invalida el registro.
* **Inmutabilidad:** Una vez creado, el ciudadano no puede editar la descripción ni la ubicación.
* **Geofencing:** Las coordenadas del reporte (si se proveen vía GPS) deben ser validadas contra un polígono geográfico predefinido (por defecto: límites de Sabinas Hidalgo). Si caen fuera, el sistema rechaza el reporte inmediatamente.

### 3.2 Máquina de Estados (State Machine)
Ciclo de vida lineal, transiciones trackeadas con timestamps precisos para SLAs:
1.  `pending`: Estado inicial.
2.  `read`: Transiciona cuando un `Mayor` u `Official` abre el reporte. Dispara `read_at`.
3.  `assigned`: Transiciona al vincular un `assignee_id` (Funcionario). Dispara `assigned_at`.
4.  `resolved`: Transiciona al marcarse como completado. Dispara `resolved_at`.

### 3.3 Reglas de Asignación y Visibilidad
* **Ciudadanos:** `SELECT * FROM reports WHERE reporter_id = current_user.id`
* **Mayor:** `SELECT * FROM reports`
* **Officials:** Visibilidad y capacidad de asignación restringida a reportes asignados a ellos mismos MÁS reportes asignados a cualquier subordinado en su rama jerárquica (requiere CTE recursiva en SQL para evitar N+1). No pueden asignar reportes hacia arriba ni a ramas paralelas.

## 4. Resolución, Evidencia y SLAs

### 4.1 Reglas de Cierre
Para pasar un reporte de `assigned` a `resolved`, el sistema exige obligatoriamente:
* Una foto adjunta de la solución (vía Active Storage).
* O una nota de resolución de al menos 50 caracteres.
* *Fallo de validación si no se cumple al menos una.*

### 4.2 Derecho de Réplica (Reapertura)
* Tras la resolución, el ciudadano tiene 72 horas para rechazar el cierre desde su PWA.
* Si rechaza, debe justificarlo. El reporte regresa a estado `assigned` con el flag `reopened: true`, penalizando las métricas del funcionario responsable.

### 4.3 Acuerdos de Nivel de Servicio (SLAs)
* **Categorías Dinámicas:** Los reportes pertenecen a una `Category` (ej. Baches, Alumbrado). Cada categoría define un SLA en horas (ej. 72h).
* **Cálculo de Tiempos:**
    * Tiempo de Respuesta: `read_at - created_at`
    * Tiempo de Acción: `resolved_at - assigned_at`
    * Tiempo Total: `resolved_at - created_at`
* Si el Tiempo Total supera el SLA de la categoría, el reporte se marca en rojo/atrasado en los dashboards.

## 5. Eventos Asíncronos y Notificaciones
* **Trigger:** Cualquier cambio en la máquina de estados del reporte.
* **Acción:** Encolar un job en Solid Queue que envíe un payload vía Web Push API al Service Worker del dispositivo del `reporter_id`. Nunca bloquear el hilo principal de la petición web.

## 6. Gestión de Organización (Offboarding)
* **Soft Delete:** Los funcionarios no se eliminan de la base de datos (`active: false`) para mantener la integridad histórica.
* **Bloqueo de Baja:** No se puede desactivar a un funcionario si tiene subordinados activos o reportes en estado `assigned`. El sistema debe forzar un flujo de reasignación hacia otro funcionario de la misma rama antes de permitir la desactivación.

## 7. Directrices de Dashboards (Consideraciones de Rendimiento)
* **Mayor:** Requiere métricas agregadas globales (Leaderboards de áreas, promedios de resolución, mapa de calor).
* **Official:** Bandeja de entrada priorizada por antigüedad, carga de trabajo de su equipo directo, reportes estancados.
* **Citizen:** Timeline visual simple de sus reportes.
* *Nota de Arquitectura:* Usar índices B-Tree en `status`, `reporter_id`, `assignee_id` y `category_id`. Considerar índices GiST para coordenadas si se usa PostGIS.
