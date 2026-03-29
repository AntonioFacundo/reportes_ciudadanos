# Diagnóstico: Eventos no llegan por Action Cable

## Flujo verificado

1. **Broadcast**: `Reports::Broadcaster.broadcast_refresh_to(report)` → Redis PUBLISH
2. **Redis**: El mensaje se publica en `rage_reports_development:{stream_name}` ✓ (verificado con MONITOR)
3. **Stream name**: Para un Report usa `report.to_gid_param` (ej: `Z2lkOi8vcmFnZS1yZXBvcnRzL1JlcG9ydC82MDgyNA`)
4. **Cliente**: `turbo_stream_from @report` genera `signed_stream_name` con el mismo stream name
5. **Suscripción**: Turbo::StreamsChannel verifica el signed name y hace `stream_from(stream_name)` → Redis SUBSCRIBE

## Posibles causas si no llegan eventos

### 1. WebSocket no conecta (ApplicationCable::Connection rechaza)

**Ubicación**: `app/channels/application_cable/connection.rb`

La conexión requiere sesión válida:
```ruby
set_current_user || reject_unauthorized_connection
```

Si `cookies.signed[:session_id]` no existe o la sesión no se encuentra, la conexión se rechaza. **Sin WebSocket = sin suscripciones = sin eventos.**

**Verificar**: Abrir DevTools → Network → filtrar "WS" → ver si hay conexión a `/cable` y su estado (101 = OK, 401/403 = rechazado).

### 2. Suscripción rechazada (signed_stream_name inválido)

Si `verified_stream_name_from_params` devuelve `nil` (verificación falla), Turbo::StreamsChannel llama `reject`. La suscripción nunca se confirma.

**Verificar**: En la pestaña Network del WebSocket, ver si llega mensaje `confirm_subscription` o `reject_subscription`.

### 3. Redis no accesible desde el proceso Rails

Si Redis no está corriendo o no es accesible (firewall, URL incorrecta), el broadcast puede fallar silenciosamente o las suscripciones no se registran.

**Verificar**:
```bash
docker exec rage_reports-redis-1 redis-cli PING   # → PONG
```

### 4. Múltiples procesos Rails (workers)

Con Puma multi-worker, cada worker tiene su propio Redis SUBSCRIBE. Si el WebSocket cae en worker A y el broadcast se hace desde worker B, ambos publican/leen del mismo Redis, así que debería funcionar. Redis es compartido.

### 5. El broadcast no se ejecuta (eventos Rage no disparan)

Si `Reports::Broadcaster.broadcast_and_notify` nunca se llama (p. ej. el flujo de eventos de Rage no llega a `OnReportEvents`), no hay nada que enviar.

**Verificar**: Ver en `log/development.log` si aparece `[ActionCable] Broadcasting to ...` cuando haces mark_read/assign/resolve.

## Comandos de prueba rápida

```bash
# 1. Redis responde
redis-cli -h localhost -p 6379 PING

# 2. Broadcast manual (con servidor corriendo y pestaña abierta en /reports/60824)
bin/rails runner "r = Report.find(60824); ActionCable.server.broadcast(r.to_gid_param, '<turbo-stream action=\"refresh\"></turbo-stream>'); puts 'OK'"
```

Si el broadcast manual hace que la pestaña se refresque, el pipeline Cable funciona y el fallo está en que el broadcast no se dispara desde las acciones (mark_read, etc.).

## Checklist rápido

- [ ] Redis corriendo: `docker compose up -d`
- [ ] Servidor Rails reiniciado tras cambiar cable.yml
- [ ] Usuario logueado (la conexión requiere sesión)
- [ ] Pestaña con /reports/60824 abierta (tiene turbo_stream_from)
- [ ] WebSocket conectado (Network → WS → /cable)
- [ ] Mensaje `confirm_subscription` en el WebSocket
