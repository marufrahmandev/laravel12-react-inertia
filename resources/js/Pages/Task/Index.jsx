import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout";
import { Head} from "@inertiajs/react";
import TasksTable from "./TasksTable";
import { Link } from "@inertiajs/react";  
export default function Index({ tasks, queryParams = null, success }) {
  return (
    <AuthenticatedLayout
     header={
        <div className="flex items-center justify-between">
          <h2 className="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            Tasks
          </h2>
          <Link
            href={route("task.create")}
            className="bg-emerald-500 py-1 px-3 text-white rounded shadow transition-all hover:bg-emerald-600"
          >
            Add new
          </Link>
        </div>
      }
    >
      <Head title="Tasks" />

      <div className="py-12">
        <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
          {success && (
            <div className="bg-emerald-500 py-2 px-4 text-white rounded mb-4">
              {success}
            </div>
          )}
        </div>
        <div className="mx-auto max-w-7xl sm:px-6 lg:px-8">
          <div className="text-white bg-white overflow-hidden  shadow-sm sm:rounded-lg dark:bg-gray-800">
            <div className="overflow-auto">
              <TasksTable
                tasks={tasks}
                queryParams={queryParams}
             
              />
            </div>
          </div>
        </div>
      </div>
    </AuthenticatedLayout>
  );
}
