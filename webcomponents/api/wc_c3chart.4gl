import util

#
# c3chart Type Def
#
public type
  tColumn dynamic array of string,
  tColumns dynamic array of tColumn,
  tTypes dictionary of string,
  tGroup dynamic array of string,
  tGroups dynamic array of tGroup,

  tData record
    x string,
    xFormat string,
    y string,
    yFormat string,
    columns tColumns,
    type string,
    types tTypes,
    groups tGroups,
    onclick string
  end record,

  tAxisType record
      type string,
      label string,
      categories dynamic array of string
    end record,
  tAxis record
    rotated boolean,
    x tAxisType,
    y tAxisType
  end record,

  tGridLines record
    show boolean,
    lines dynamic array of string
  end record,
  tGrid record
    x tGridLines,
    y tGridLines
  end record,

  tLegend record
    position string,
    show boolean
  end record,

  tTooltip record
    show boolean,
    grouped boolean,
    format string
  end record,

  tPadding record
    top string,
    right string,
    bottom string,
    left string
  end record,

  tColor record
    pattern dynamic array of string
  end record,
  
  tDoc record
    data tData,
    axis tAxis,
    grid tGrid,
    legend tLegend,
    tooltip tTooltip,
    padding tPadding,
    color tColor
  end record,

  tChart record
    field string,
    title string,
    narrative string,
    showfocus boolean,
    doc tDoc
  end record,

  tElement record
    x string,
    value string,
    id string,
    index string,
    name string
  end record

public define
  m_trace boolean


  
#
#! Init
#+ Initialize
#+
#+ @code
#+ call wc_c3chart.Init()
#
public function Init()

  let m_trace = FALSE
  
end function



#
#! Create
#+ Creates a new instance of Chart
#+
#+ @param p_field     Form name of the field
#+ @returnType        tChart
#+ @return            Chart record
#+
#+ @code
#+ define r_acc wc_c3chart.tChart
#+ call wc_c3chart.Create("formonly.p_chart") returning r_chart.*
#
public function Create(p_field string) returns tChart

  define
    r_chart tChart


  -- Field name of widget
  let r_chart.field = p_field

  -- Set defaults
  let r_chart.doc.axis.rotated = FALSE
  let r_chart.doc.legend.show = TRUE
  let r_chart.doc.tooltip.show = TRUE

  return r_chart.*
  
end function


#
#! Column_Set
#+ Set tColumn of data from JSONArray string
#+
#+ @param p_json    JSON array of strings
#+
#+ @code
#+ define p_json string, o_col tColumn
#+ call wc_color.Column_Set('["alpha","100","180","240"]') returning o_col
#
public function Column_Set(p_json string) returns tColumn

  define
    o_jArr util.JSONArray,
    a_col tColumn

  let o_jArr = util.JSONArray.parse(p_json)
  call o_jArr.toFGL(a_col)
  
  return a_col
  
end function


#
#! Domain
#+ Returns list of possible values in a domain
#+
#+ @param p_domain    Domain to return possible values of
#+
#+ @code
#+ define a_list dynamic array of string
#+ call wc_c3chart.Domain("chart_type") returning a_list
#

public function Domain(p_domain string) returns dynamic array of string

  define
    a_list dynamic array of string,
    i integer

  case p_domain.toUpperCase()
    when "CHART_TYPE"
      let i = 0
      let a_list[i:=i+1] = ""
      let a_list[i:=i+1] = "line"
      let a_list[i:=i+1] = "spline"
      let a_list[i:=i+1] = "step"
      let a_list[i:=i+1] = "area"
      let a_list[i:=i+1] = "area-spline"
      let a_list[i:=i+1] = "area-step"
      let a_list[i:=i+1] = "bar"
      let a_list[i:=i+1] = "scatter"
      let a_list[i:=i+1] = "pie"
      let a_list[i:=i+1] = "donut"
      let a_list[i:=i+1] = "gauge"
    when "AXIS_TYPE"
      let i = 0
      let a_list[i:=i+1] = ""
      let a_list[i:=i+1] = "indexed"
      let a_list[i:=i+1] = "category"
      let a_list[i:=i+1] = "timeseries"
    when "POSITION"
      let i = 0
      let a_list[i:=i+1] = ""
      let a_list[i:=i+1] = "bottom"
      let a_list[i:=i+1] = "right"
      let a_list[i:=i+1] = "inset"
  end case
  
  return a_list

end function



#
#! Set
#+ Set initial contents of widget
#+
#+ @param r_chart  Chart instance
#+
#+ @code
#+ define r_chart tChart
#+ let r_chart.data.x = "x"
#+ ...
#+ call wc_c3chart.Set(r_chart.*)
#
public function Set(r_chart tChart)

  call ui.Interface.frontCall("webcomponent", "call", [r_chart.field, "Set", Serialize(r_chart.*)], [])
  
end function


#
#! Element
#+ DeSerialize a selected chart element
#+
#+ @param p_json    JSON encoded element
#+ @returnType      tElement
#+ @return          Element record
#+
#+ @code
#+ define r_element tElement, p_json string
#+ call wc_c3chart.Element(p_json) returning r_element
#
public function Element(p_json string) returns tElement

  define
    r_element tElement


  call trace(p_json)
  if (p_json.getLength())
  then
    call util.JSON.parse(p_json, r_element)
  end if

  return r_element.*
  
end function



#
#! Serialize
#+ Serialize a chart
#+
#+ @param r_chart   tChart
#+
#+ @returnType string
#+ @return JSON string of tChart.doc structure
#+
#+ @code
#+ define r_chart wc_c3chart.tChart,
#+   p_json string
#+ let p_json = wc_c3chart.Serialize(r_chart.*)
#
public function Serialize(r_chart tChart) returns string

  call trace(util.JSON.stringify(r_chart))
  return util.JSON.stringify(r_chart)
  
end function




#
# PRIVATE
#

#
#! trace
#+ Dump argument string as trace to output if trace enabled
#+
#+ @param     Data string to dump to output
#+
#+ @code
#+ call trace('here i am')
#
private function trace(p_data string)

  if m_trace
  then
    display p_data
  end if

end function