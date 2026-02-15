/**
 * @description Utility class for centralized logging
 * @author PWChrono Team
 */
public without sharing class PWChrono_Logger {
  public static void error(String message) {
    System.debug(LoggingLevel.ERROR, '[PWChrono] ERROR: ' + message);
  }

  public static void error(String message, Exception e) {
    System.debug(
      LoggingLevel.ERROR,
      '[PWChrono] ERROR: ' +
        message +
        '\nStack Trace: ' +
        e.getStackTraceString()
    );
  }

  public static void warn(String message) {
    System.debug(LoggingLevel.WARN, '[PWChrono] WARN: ' + message);
  }

  public static void info(String message) {
    System.debug(LoggingLevel.INFO, '[PWChrono] INFO: ' + message);
  }
}