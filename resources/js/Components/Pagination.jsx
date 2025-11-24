import { Link } from "@inertiajs/react";

export default function Pagination({ links, queryParams }) {
  let extraQuery = new URLSearchParams();
  if(queryParams?.status){
    extraQuery.append("status", queryParams.status);
  }
  if(queryParams?.name){
    extraQuery.append("name", queryParams.name);
  }
   if(queryParams?.email){
    extraQuery.append("email", queryParams.email);
  }
  if(queryParams?.sort_field){
    extraQuery.append("sort_field", queryParams.sort_field);
  }
  if(queryParams?.sort_direction){
    extraQuery.append("sort_direction", queryParams.sort_direction);
  }
  return (
    <nav className="text-center mt-4">
      {links.map((link) => (
        <Link
          preserveScroll
          href={(link.url? (link.url + "&" +  extraQuery.toString()): "")}
          key={link.label}
          className={
            "inline-block py-2 px-3 rounded-lg text-gray-200 text-xs " +
            (link.active ? "bg-gray-950 " : " ") +
            (!link.url
              ? "!text-gray-500 cursor-not-allowed "
              : "hover:bg-gray-950")
          }
          dangerouslySetInnerHTML={{ __html: link.label }}
        ></Link>
      ))}
    </nav>
  );
}