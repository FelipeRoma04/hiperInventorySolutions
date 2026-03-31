package com.hiper.inventory.utils;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utilidad para generar y validar OTP (One-Time Passwords) para 2FA TOTP
 */
public class OTPGenerator {
    
    private static final int SECRET_SIZE = 32;
    private static final SecureRandom secureRandom = new SecureRandom();
    
    /**
     * Genera un secret key para TOTP
     * @return Secret key en base64
     */
    public static String generateSecret() {
        byte[] randomBytes = new byte[SECRET_SIZE];
        secureRandom.nextBytes(randomBytes);
        return Base64.getEncoder().encodeToString(randomBytes);
    }
    
    /**
     * Genera códigos de backup (10 códigos de 8 dígitos cada uno)
     * @return Array de códigos de backup
     */
    public static String[] generateBackupCodes() {
        String[] codes = new String[10];
        for (int i = 0; i < 10; i++) {
            codes[i] = String.format("%08d", secureRandom.nextInt(100000000));
        }
        return codes;
    }
    
    /**
     * Valida un código OTP (TOTP) contra un secret
     * Tolerancia de ±1 ventana de tiempo (30 segundos)
     * @param secret El secret key en base64
     * @param otp El código OTP a validar
     * @return true si es válido
     */
    public static boolean validateTOTP(String secret, String otp) {
        try {
            Long[] acceptedCodes = getTOTPCodes(secret);
            String otpStr = String.format("%06d", Long.parseLong(otp));
            
            for (Long code : acceptedCodes) {
                if (code.toString().equals(otpStr)) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Obtiene códigos TOTP aceptables (actual ±1)
     * @param secret El secret key en base64
     * @return Array de códigos válidos
     */
    private static Long[] getTOTPCodes(String secret) {
        Long[] codes = new Long[3];
        long currentTime = System.currentTimeMillis();
        
        for (int i = -1; i <= 1; i++) {
            long timeWindow = (currentTime / 30000) + i;
            codes[i + 1] = generateHOTP(secret, timeWindow);
        }
        
        return codes;
    }
    
    /**
     * Genera un código HOTP
     * @param secret El secret key en base64
     * @param counter El counter para HOTP
     * @return El código generado
     */
    private static Long generateHOTP(String secret, long counter) {
        try {
            byte[] decodedKey = Base64.getDecoder().decode(secret);
            
            // HMAC-SHA1
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA1");
            javax.crypto.spec.SecretKeySpec keySpec = 
                new javax.crypto.spec.SecretKeySpec(decodedKey, 0, decodedKey.length, "HmacSHA1");
            mac.init(keySpec);
            
            byte[] hash = mac.doFinal(longToByteArray(counter));
            
            int offset = hash[hash.length - 1] & 0xf;
            long code = ((hash[offset] & 0x7f) << 24) |
                       ((hash[offset + 1] & 0xff) << 16) |
                       ((hash[offset + 2] & 0xff) << 8) |
                       (hash[offset + 3] & 0xff);
            
            return code % 1000000;
        } catch (Exception e) {
            throw new RuntimeException("Error al generar HOTP", e);
        }
    }
    
    /**
     * Convierte un long a byte array (big-endian)
     */
    private static byte[] longToByteArray(long num) {
        byte[] byteArray = new byte[8];
        for (int i = 7; i >= 0; i--) {
            byteArray[i] = (byte) (num & 0xff);
            num >>= 8;
        }
        return byteArray;
    }
    
    /**
     * Genera un código temporal OTP para SMS
     * @return Código de 6 dígitos
     */
    public static String generateSMSCode() {
        return String.format("%06d", secureRandom.nextInt(1000000));
    }
    
    /**
     * Genera QR code URL para Google Authenticator
     * @param secret El secret key
     * @param email Email del usuario
     * @param issuer Nombre de la aplicación
     * @return URL para generar código QR
     */
    public static String getQRCodeURL(String secret, String email, String issuer) {
        return String.format(
            "otpauth://totp/%s:%s?secret=%s&issuer=%s",
            issuer, email, secret, issuer
        );
    }
}
