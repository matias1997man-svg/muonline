-- ============================================================================
-- VIP acumulable (KhadesMU) - 26/11/2026
-- Correr en la base MuOnline del VPS (SQL Server Management Studio).
--
-- ANTES: guardar el procedimiento actual por si hay que volver atras:
--     EXEC sp_helptext 'WZ_SetAccountLevel'
-- (copiar el resultado a un .txt)
--
-- Comportamiento nuevo:
--   * VIP activo del mismo nivel -> los dias se SUMAN al vencimiento actual
--     (compra 30 dias, usa 15, compra 30 mas -> le quedan 45).
--   * Sin VIP, o VIP ya vencido -> 30 dias contados desde ahora.
--     (el original sumaba sobre la fecha vieja vencida y el jugador perdia dias)
-- ============================================================================

ALTER PROCEDURE [dbo].[WZ_SetAccountLevel]
	@inAccountID VARCHAR(10),
	@inAccountLevel INT,
	@inAccountExpireTime INT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION

	UPDATE MEMB_INFO
	SET AccountLevel = @inAccountLevel,
		AccountExpireDate = CASE
			WHEN AccountLevel = @inAccountLevel AND AccountExpireDate > GETDATE()
			THEN DATEADD(SECOND, @inAccountExpireTime, AccountExpireDate)
			ELSE DATEADD(SECOND, @inAccountExpireTime, GETDATE())
		END
	WHERE memb___id = @inAccountID

	IF @@ERROR = 0
		COMMIT TRANSACTION
	ELSE
		ROLLBACK TRANSACTION

	SET NOCOUNT OFF
END
GO

-- Verificacion (cambiar 'cuenta' por una cuenta de prueba):
-- SELECT memb___id, AccountLevel, AccountExpireDate FROM MEMB_INFO WHERE memb___id = 'cuenta'
