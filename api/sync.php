<?php
// api/sync.php - Manejo de sincronización
function handleSync($pdo, $method, $table) {
    $syncModel = new SyncModel($pdo);
    
    switch ($method) {
        case 'POST':
            // Sincronizar datos individuales
            $input = json_decode(file_get_contents('php://input'), true);
            $operation = $input['operation'] ?? 'INSERT';
            $data = $input['data'] ?? [];
            
            try {
                $result = $syncModel->syncData($table, $data, $operation);
                echo json_encode($result);
            } catch (Exception $e) {
                http_response_code(400);
                echo json_encode(['error' => $e->getMessage()]);
            }
            break;
            
        case 'GET':
            // Obtener cambios desde última sincronización
            $lastSync = $_GET['lastSync'] ?? '1970-01-01 00:00:00';
            
            try {
                $changes = $syncModel->getChangesSince($table, $lastSync);
                echo json_encode([
                    'success' => true,
                    'table' => $table,
                    'changes' => $changes,
                    'count' => count($changes),
                    'lastSync' => date('Y-m-d H:i:s')
                ]);
            } catch (Exception $e) {
                http_response_code(400);
                echo json_encode(['error' => $e->getMessage()]);
            }
            break;
            
        case 'PUT':
            // Sincronización masiva
            $input = json_decode(file_get_contents('php://input'), true);
            $batch = $input['batch'] ?? [];
            
            try {
                $results = [];
                $pdo->beginTransaction();
                
                foreach ($batch as $item) {
                    $result = $syncModel->syncData(
                        $item['table'], 
                        $item['data'], 
                        $item['operation']
                    );
                    $results[] = $result;
                }
                
                $pdo->commit();
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Sincronización masiva completada',
                    'results' => $results
                ]);
                
            } catch (Exception $e) {
                $pdo->rollBack();
                http_response_code(400);
                echo json_encode(['error' => $e->getMessage()]);
            }
            break;
            
        default:
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
    }
}

function handleBackup($pdo) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Método no permitido']);
        return;
    }
    
    try {
        $backupData = [];
        $tables = ['estudiantes', 'docentes', 'materias', 'asistencias', 'usuarios'];
        
        foreach ($tables as $table) {
            $stmt = $pdo->query("SELECT * FROM $table");
            $backupData[$table] = $stmt->fetchAll();
        }
        
        $backupId = 'backup_' . date('Y-m-d_H-i-s');
        $filename = "../backups/$backupId.json";
        
        file_put_contents($filename, json_encode($backupData, JSON_PRETTY_PRINT));
        
        // Registrar en base de datos
        $stmt = $pdo->prepare("
            INSERT INTO respaldos (id, tipo_respaldo, descripcion, ruta_archivo, usuario_respaldo, tamano_bytes)
            VALUES (?, 'AUTOMATICO', 'Respaldo automático del sistema', ?, 'sistema', ?)
        ");
        
        $stmt->execute([
            $backupId,
            $filename,
            filesize($filename)
        ]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Respaldo creado exitosamente',
            'backup_id' => $backupId,
            'file_size' => filesize($filename)
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error creando respaldo: ' . $e->getMessage()]);
    }
}

function handleRestore($pdo) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Método no permitido']);
        return;
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    $backupId = $input['backup_id'] ?? '';
    
    if (empty($backupId)) {
        http_response_code(400);
        echo json_encode(['error' => 'ID de respaldo requerido']);
        return;
    }
    
    $filename = "../backups/$backupId.json";
    
    if (!file_exists($filename)) {
        http_response_code(404);
        echo json_encode(['error' => 'Archivo de respaldo no encontrado']);
        return;
    }
    
    try {
        $backupData = json_decode(file_get_contents($filename), true);
        
        $pdo->beginTransaction();
        
        foreach ($backupData as $table => $records) {
            // Limpiar tabla (opcional, dependiendo de la estrategia)
            // $pdo->exec("DELETE FROM $table");
            
            foreach ($records as $record) {
                $columns = implode(', ', array_keys($record));
                $placeholders = ':' . implode(', :', array_keys($record));
                
                $sql = "INSERT INTO $table ($columns) VALUES ($placeholders) 
                        ON DUPLICATE KEY UPDATE ";
                
                $updates = [];
                foreach ($record as $key => $value) {
                    if ($key !== 'id') {
                        $updates[] = "$key = VALUES($key)";
                    }
                }
                $sql .= implode(', ', $updates);
                
                $stmt = $pdo->prepare($sql);
                $stmt->execute($record);
            }
        }
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Restauración completada exitosamente',
            'tables_restored' => count($backupData)
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'Error en restauración: ' . $e->getMessage()]);
    }
}
?>