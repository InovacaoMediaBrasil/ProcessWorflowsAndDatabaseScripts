USE CanalDoArtesanato_Production;

SELECT 
U1.UserId AS 'C�digo',
CONVERT(VARCHAR, U1.RegisterDate, 103) AS 'Data de cadastro', 
CONVERT(VARCHAR, U1.LastAccessDate, 103) AS 'Data de �ltimo acesso',
CONVERT(VARCHAR, H1.StartDate, 103) AS 'Data de altera��o do estado financeiro',
CONVERT(VARCHAR, T1.Date, 103) AS 'Data do pagamento',
CASE 
	WHEN F1.FinancialState = 1 THEN 'Incompleto'
	WHEN F1.FinancialState = 2 THEN 'M�s gr�tis'
	WHEN F1.FinancialState = 3 THEN 'Assinante'
	WHEN F1.FinancialState = 4 THEN 'Aguardando Pagamento'
	WHEN F1.FinancialState = 5 THEN 'Congelado'
	WHEN F1.FinancialState = 6 THEN 'Cancelado'
END AS 'Status financeiro atual',
ISNULL((SELECT CASE 
	WHEN F2.FinancialState = 1 THEN 'Incompleto'
	WHEN F2.FinancialState = 2 THEN 'M�s gr�tis'
	WHEN F2.FinancialState = 3 THEN 'Assinante'
	WHEN F2.FinancialState = 4 THEN 'Aguardando Pagamento'
	WHEN F2.FinancialState = 5 THEN 'Congelado'
	WHEN F2.FinancialState = 6 THEN 'Cancelado'
END 
	FROM UsersFinancialStatesHistories AS F2 WITH (NOLOCK) 
	WHERE F2.UserId = U1.UserId 
	AND F2.EndDate = (
		SELECT MAX(F3.EndDate) 
		FROM UsersFinancialStatesHistories AS F3 WITH (NOLOCK) 
		WHERE F3.UserId = U1.UserId
	)), 'Novo assinante')
AS 'Status financeiro anterior',
CASE 
	WHEN T1.Method = 1 THEN 'Recorr�ncia'
	WHEN T1.Method = 2 THEN 'Cart�o de cr�dito - M�quina'
	WHEN T1.Method = 3 THEN 'Boleto - Anual'
	WHEN T1.Method = 4 THEN 'Dinheiro'
	WHEN T1.Method = 5 THEN 'Cart�o de d�bito'
	WHEN T1.Method = 6 THEN 'Voucher'
	WHEN T1.Method = 7 THEN 'Cart�o de presente'
	WHEN T1.Method = 8 THEN 'Sankhya'
	WHEN T1.Method = 9 THEN 'Boleto - Semestral'
	WHEN T1.Method = 10 THEN 'Boleto - Trimestral'
	WHEN T1.Method = 11 THEN 'Cart�o de Cr�dito - Gateway'
	WHEN T1.Method = 12 THEN 'PayPal'
END AS 'Forma de Pagamento'
FROM Users AS U1 WITH (NOLOCK)
INNER JOIN UsersHowKnows AS H1 WITH (NOLOCK)
ON H1.SubscriberId = U1.UserId 
INNER JOIN UsersFinancialStatesHistories AS F1 WITH (NOLOCK)
ON F1.UserId = U1.UserId
INNER JOIN Transactions AS T1 WITH (NOLOCK)
ON T1.UserId = U1.UserId
WHERE H1.EndDate IS NULL
AND H1.HowKnowId = 89257 -- Igor Pamplona
AND U1.HierarchyLevel = 3 -- Assinantes
AND F1.EndDate IS NULL --Estado atual
AND T1.Date = (SELECT MAX(T2.Date) FROM Transactions AS T2 WITH (NOLOCK) WHERE T2.UserId = U1.UserId) --�ltima transa��o
AND F1.FinancialState = 3 --Somente os com pagamento ativo
AND F1.StartDate >= '2018-08-01'
ORDER BY F1.FinancialState, T1.Method