<?php
// api/models/SyncModel.php - Manejo de sincronización
class SyncModel {
    private $pdo;
    
    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    public function syncData($table, $data, $operation) {
        $allowedTables = [
            'estudiantes', 'docentes', 'materias', 'asistencias', 
            'detalle_asistencias', 'notas_asistencia', 'huellas_biometricas',
            'carreras', 'turnos', 'niveles', 'paralelos', 'periodos_academicos',
            'bimestres', 'docente_materia', 'horarios_clases', 'asistencia_diaria'
        ];
        
        if (!in_array($table, $allowedTables)) {
            throw new Exception('Tabla no permitida: ' . $table);
        }
        
        switch ($operation) {
            case 'INSERT':
                return $this->insertData($table, $data);
            case 'UPDATE':
                return $this->updateData($table, $data);
            case 'DELETE':
                return $this->deleteData($table, $data);
            default:
                throw new Exception('Operación no válida: ' . $operation);
        }
    }
    
    private function insertData($table, $data) {
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));
        
        $sql = "INSERT INTO $table ($columns) VALUES ($placeholders)";
        $stmt = $this->pdo->prepare($sql);
        
        try {
            $stmt->execute($data);
            return [
                'success' => true,
                'message' => 'Registro insertado',
                'affected_rows' => $stmt->rowCount()
            ];
        } catch (PDOException $e) {
            // Si es duplicado, intentar actualizar
            if ($e->getCode() == 23000) {
                return $this->updateData($table, $data);
            }
            throw $e;
        }
    }
    
    private function updateData($table, $data) {
        if (!isset($data['id'])) {
            throw new Exception('Se requiere ID para actualizar');
        }
        
        $setClause = [];
        foreach ($data as $key => $value) {
            if ($key !== 'id') {
                $setClause[] = "$key = :$key";
            }
        }
        
        $sql = "UPDATE $table SET " . implode(', ', $setClause) . " WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($data);
        
        return [
            'success' => true,
            'message' => 'Registro actualizado',
            'affected_rows' => $stmt->rowCount()
        ];
    }
    
    private function deleteData($table, $data) {
        if (!isset($data['id'])) {
            throw new Exception('Se requiere ID para eliminar');
        }
        
        $sql = "DELETE FROM $table WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $data['id']]);
        
        return [
            'success' => true,
            'message' => 'Registro eliminado',
            'affected_rows' => $stmt->rowCount()
        ];
    }
    
    public function getChangesSince($table, $lastSync) {
        $timestampColumns = [
            'estudiantes' => 'fecha_actualizacion',
            'docentes' => 'fecha_actualizacion',
            'materias' => 'updated_at',
            'asistencias' => 'ultima_actualizacion',
            'detalle_asistencias' => 'fecha',
            'usuarios' => 'updated_at'
        ];
        
        $column = $timestampColumns[$table] ?? 'fecha_creacion';
        
        $sql = "SELECT * FROM $table WHERE $column > ? ORDER BY $column LIMIT " . Config::MAX_SYNC_RECORDS;
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$lastSync]);
        
        return $stmt->fetchAll();
    }
    
    public function getTableStructure($table) {
        $stmt = $this->pdo->prepare("DESCRIBE $table");
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
?>