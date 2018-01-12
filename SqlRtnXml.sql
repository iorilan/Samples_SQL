

--return xml result
SELECT e.EmployeeID, c.FirstName, c.MiddleName, c.LastName
FROM HumanResources.Employee e INNER JOIN Person.Contact c
   ON c.ContactID = e.ContactID
WHERE c.FirstName = 'Rob'
FOR XML RAW;

--to be make details