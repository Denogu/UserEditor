<!--- TOOL DRAWER:  contains useful function(s) --->

<!--- Thanks Ben Nadel --->
<cffunction name="QueryToCSV" access="public" returntype="string" output="false" hint="I take a query and convert it to a comma separated value string.">
  <cfargument name="Query" type="query" required="true" hint="I am the query being converted to CSV.">
  <cfargument name="Fields" type="string" required="true" hint="I am the list of query fields to be used when creating the CSV value.">
  <cfargument name="CreateHeaderRow" type="boolean" required="false" default="true" hint="I flag whether or not to create a row of header values.">
  <cfargument name="Delimiter" type="string" required="false" default="," hint="I am the field delimiter in the CSV value.">

  <cfset var LOCAL = {}>

  <cfset LOCAL.ColumnNames = {}>

  <cfloop index="LOCAL.ColumnName" list="#ARGUMENTS.Fields#" delimiters=",">
    <cfset LOCAL.ColumnNames[ StructCount( LOCAL.ColumnNames ) + 1 ] = Trim( LOCAL.ColumnName )>
  </cfloop>

  <cfset LOCAL.ColumnCount = StructCount( LOCAL.ColumnNames )>

  <cfset LOCAL.Buffer = CreateObject( "java", "java.lang.StringBuffer" ).Init()>

  <cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 ))>

  <cfif ARGUMENTS.CreateHeaderRow>
    <cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
      <cfset LOCAL.Buffer.Append( JavaCast( "string", """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" ) )>
      
      <cfif (LOCAL.ColumnIndex LT LOCAL.ColumnCount)>
        <cfset LOCAL.Buffer.Append( JavaCast( "string", ARGUMENTS.Delimiter ) )>
      <cfelse>
        <cfset LOCAL.Buffer.Append( JavaCast( "string", LOCAL.NewLine ) )>
      </cfif>
    </cfloop>
  </cfif>

  <cfloop query="ARGUMENTS.Query">
    <cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">
      <cfset LOCAL.Buffer.Append( JavaCast( "string", """#ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ]#""" ) )>

      <cfif (LOCAL.ColumnIndex LT LOCAL.ColumnCount)>
        <cfset LOCAL.Buffer.Append( JavaCast( "string", ARGUMENTS.Delimiter ) )>
      <cfelse>
        <cfset LOCAL.Buffer.Append( JavaCast( "string", LOCAL.NewLine ) )>
      </cfif>
    </cfloop>
  </cfloop>
  
  <cfreturn LOCAL.Buffer.ToString()>
</cffunction>


<!--- FROM: http://www.bennadel.com/blog/149-Ask-Ben-Converting-A-Query-To-A-Struct.htm --->
<cffunction name="QueryToStruct" access="public" returntype="any" output="false"
  hint="Converts an entire query or the given record to a struct. This might return a structure (single record) or an array of structures.">

  <!--- Define arguments. --->
  <cfargument name="Query" type="query" required="true" />
  <cfargument name="Row" type="numeric" required="false" default="0" />

  <cfscript>

  // Define the local scope.
  var LOCAL = StructNew();

  // Determine the indexes that we will need to loop over.
  // To do so, check to see if we are working with a given row,
  // or the whole record set.
  if (ARGUMENTS.Row){

  // We are only looping over one row.
  LOCAL.FromIndex = ARGUMENTS.Row;
  LOCAL.ToIndex = ARGUMENTS.Row;

  } else {

  // We are looping over the entire query.
  LOCAL.FromIndex = 1;
  LOCAL.ToIndex = ARGUMENTS.Query.RecordCount;

  }

  // Get the list of columns as an array and the column count.
  LOCAL.Columns = ListToArray( ARGUMENTS.Query.ColumnList );
  LOCAL.ColumnCount = ArrayLen( LOCAL.Columns );

  // Create an array to keep all the objects.
  LOCAL.DataArray = ArrayNew( 1 );

  // Loop over the rows to create a structure for each row.
  for (LOCAL.RowIndex = LOCAL.FromIndex ; LOCAL.RowIndex LTE LOCAL.ToIndex ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){

  // Create a new structure for this row.
  ArrayAppend( LOCAL.DataArray, StructNew() );

  // Get the index of the current data array object.
  LOCAL.DataArrayIndex = ArrayLen( LOCAL.DataArray );

  // Loop over the columns to set the structure values.
  for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE LOCAL.ColumnCount ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){

  // Get the column value.
  LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];

  // Set column value into the structure.
  LOCAL.DataArray[ LOCAL.DataArrayIndex ][ LOCAL.ColumnName ] = ARGUMENTS.Query[ LOCAL.ColumnName ][ LOCAL.RowIndex ];

  }

  }


  // At this point, we have an array of structure objects that
  // represent the rows in the query over the indexes that we
  // wanted to convert. If we did not want to convert a specific
  // record, return the array. If we wanted to convert a single
  // row, then return the just that STRUCTURE, not the array.
  if (ARGUMENTS.Row){

  // Return the first array item.
  return( LOCAL.DataArray[ 1 ] );

  } else {

  // Return the entire array.
  return( LOCAL.DataArray );

  }

  </cfscript>
</cffunction>




<cffunction name="queryColumnToArray" access="public" returntype="array" output="false" hint="I convert query column to array">
	<cfargument name="Query" type="query" required="true">
    <cfargument name="columnName" type="string" required="true" hint="I am the query column which needs to be converted to an array.">
    
    <cfset local = {} />
    <cfset local.columnArray = ArrayNew(1) />
    
    <cfloop index="i" from=1 to="#arguments.Query.recordCount#">
    	<cfset arrayAppend(local.columnArray, arguments.Query[columnName][i]) />
    </cfloop>
    
    <cfreturn local.columnArray />
</cffunction>    





