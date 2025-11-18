<?php
// api/config.php - Configuración de la base de datos
class Config {
    const DB_HOST = 'localhost';
    const DB_NAME = 'incos_check';
    const DB_USER = 'root';
    const DB_PASS = '';
    const DB_CHARSET = 'utf8mb4';
    
    // Configuración de JWT
    const JWT_SECRET = 'incos_check_secret_key_2024';
    const JWT_EXPIRE = 86400; // 24 horas
    
    // Configuración de la aplicación
    const APP_VERSION = '1.0.0';
    const MAX_SYNC_RECORDS = 1000;
}

// Headers de seguridad
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
?>