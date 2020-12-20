DECLARE 
@RemoveUserId INT,
@UpdateUserId INT;

/* =============== Altere as duas variav�is abaixo apenas! =============== */
/* Usu�rio que foi criado por �ltimo, que ser� removido do sistema */
SET @RemoveUserId = 0;

/* Usu�rio que vai permancer no sistema*/
SET @UpdateUserId = 0;

/* ======================================================================= */





/* ================= N�o altere as linhas a partir daqui ================= */

/* Transfere pagamentos */
UPDATE Transactions SET UserId = @UpdateUserId WHERE UserId = @RemoveUserId;
UPDATE TransactionsPayments SET UserId = @UpdateUserId WHERE UserId = @RemoveUserId;
UPDATE TransactionsBankBills SET UserId = @UpdateUserId WHERE UserId = @RemoveUserId;
/* Altera o status atual do usu�rio que vai finalizado, ser� usado o estado do usu�rio duplicado (que ser� removido) */
UPDATE UsersFinancialStatesHistories SET EndDate = GETDATE() WHERE EndDate IS NULL AND UserId = @RemoveUserId;
/* Copia o hist�rico de estados financeiros */
UPDATE TransactionsRecurringPayments SET UserId = @UpdateUserId WHERE UserId = @RemoveUserId;
/* Remove os como soube do usu�rio que ser� apagado - sem copiar ele para o antigo */
DELETE FROM UsersHowKnows WHERE SubscriberId = @RemoveUserId;
/* Remove o usu�rio que deve ser apagado*/
DELETE FROM Users WHERE UserId = @RemoveUserId;