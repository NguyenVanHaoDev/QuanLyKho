using System.Data;
using QLKHO.DLL;

namespace QLKHO.BLL
{
	public class EmployeeService
	{
		private readonly EmployeeRepository _repository;

		public EmployeeService()
		{
			_repository = new EmployeeRepository();
		}

		public DataTable GetTopEmployees(int top = 1000)
		{
			return _repository.GetTopEmployees(top);
		}
	}
}


