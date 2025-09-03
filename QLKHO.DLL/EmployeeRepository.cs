using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace QLKHO.DLL
{
	public class EmployeeRepository
	{
		private readonly string _connectionString;

		public EmployeeRepository()
		{
			_connectionString = ConfigurationManager.ConnectionStrings["QLBH_Connection"].ConnectionString;
		}

		public DataTable GetTopEmployees(int top = 1000)
		{
			var dataTable = new DataTable();
			using (var connection = new SqlConnection(_connectionString))
			using (var command = new SqlCommand(@"SELECT TOP (@Top)
				[EmployeeID],
				[EmployeeCode],
				[FullName],
				[Gender],
				[DateOfBirth],
				[PhoneNumber],
				[Email],
				[CitizenID],
				[PhotoFileName],
				[Address],
				[HireDate],
				[StatusCode]
			FROM [HR_MANAGEMENT].[dbo].[EMP_TBL]", connection))
			{
				command.Parameters.Add(new SqlParameter("@Top", SqlDbType.Int) { Value = top });
				using (var adapter = new SqlDataAdapter(command))
				{
					adapter.Fill(dataTable);
				}
			}
			return dataTable;
		}
	}
}


