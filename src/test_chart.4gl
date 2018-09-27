#
# test_chart.4gl  Unit tests for wc_c3chart
#

import security

import FGL fgldialog
import FGL wc_c3chart


private define
  mr_chart wc_c3chart.tChart,
  m_chart string,
  ma_columns dynamic array of record
      col_type string,
      data1 string,
      data2 string,
      data3 string,
      data4 string,
      data5 string,
      data6 string,
      data7 string
    end record

  


#
#! Setup
#
private function Setup()  
  call wc_c3chart.Init()
end function


#
#! Teardown
#
private function Teardown()
end function



#
#! Test
#
public function Test()

  define
    r_element wc_c3chart.tElement
    

  call Setup()

  -- Init
  call wc_c3chart.Create("formonly.p_chart") returning mr_chart.*
  let mr_chart.title = "Power Profile"
  let mr_chart.narrative = "Results of Standing Starts"
  let r_element.id = NULL
  
  -- Load some content & defaults
  call Load(mr_chart.*, r_element.*)
  call Table("SET")
  let mr_chart.doc.data.type = "spline"
  let mr_chart.doc.axis.x.label = "Effort"
  let mr_chart.doc.axis.y.label = "Watts"
  
  -- Open screen and display initial
  open window w_test with form "test_chart"
    attributes(style = "app")
  call combo_List("type", "CHART_TYPE")  
  call combo_List("x_type", "AXIS_TYPE")  
  call combo_List("y_type", "AXIS_TYPE")  
  call combo_List("legend_position", "POSITION")  
  call combo_List("col_type", "CHART_TYPE")  
  call wc_c3chart.Set(mr_chart.*)

  -- Interact
  dialog attributes(unbuffered)
    subdialog chart_Head
    subdialog chart_Data
    subdialog chart_Columns

    on action select attribute(defaultview=no)
      -- Get the element that was selected
      call wc_c3chart.Element(m_chart)
        returning r_element.*
        
      -- Load next set of data based on user selected element & Refresh
      message "Fetch data for: " || m_chart
      call Load(mr_chart.*, r_element.*)
      call wc_c3chart.Set(mr_chart.*)
      
    on action close
      exit dialog
  end dialog

  close window w_test
  call Teardown()
  
end function



#
#! Load
#

public function Load(r_chart wc_c3chart.tChart, r_element wc_c3chart.tElement)

  define
    p_max, i,j integer

  case
    when r_element.id is NULL
      let i = 0
      call wc_c3chart.Column_Set('["Alpha","0","50","100","150","200","250"]') returning r_chart.doc.data.columns[i:=i+1]
      call wc_c3chart.Column_Set('["Beta","30","200","100","400","150","250"]') returning r_chart.doc.data.columns[i:=i+1]
      call wc_c3chart.Column_Set('["Gamma","50","20","10","40","15","25"]') returning r_chart.doc.data.columns[i:=i+1]
      call wc_c3chart.Column_Set('["Delta","150","180","200","300","240","350"]') returning r_chart.doc.data.columns[i:=i+1]
      call wc_c3chart.Column_Set('["Epsilon","80","200","150","290","110","220"]') returning r_chart.doc.data.columns[i:=i+1]
      
    otherwise
      -- Simulate fetching data for selected element, load some random data
      let p_max = 500
      for j = 1 to 5
        for i = 2 to 7
          let r_chart.doc.data.columns[j,i] = random_Data(p_max)
        end for
      end for
  end case
  
end function


#
#! Table
#
function Table(p_direction string)
  define
    idx integer

  -- Clear column types
  call mr_chart.doc.data.types.clear()
  
  case p_direction.toUpperCase()
    when "SET"
      -- Load data to Table from Chart
      for idx = 1 to mr_chart.doc.data.columns.getLength()
        let ma_columns[idx].data1 = mr_chart.doc.data.columns[idx,1]
        let ma_columns[idx].data2 = mr_chart.doc.data.columns[idx,2]
        let ma_columns[idx].data3 = mr_chart.doc.data.columns[idx,3]
        let ma_columns[idx].data4 = mr_chart.doc.data.columns[idx,4]
        let ma_columns[idx].data5 = mr_chart.doc.data.columns[idx,5]
        let ma_columns[idx].data6 = mr_chart.doc.data.columns[idx,6]
        let ma_columns[idx].data7 = mr_chart.doc.data.columns[idx,7]

        -- Check if column type defined
        if mr_chart.doc.data.types.contains(ma_columns[idx].data1)
        then
          let ma_columns[idx].col_type = mr_chart.doc.data.types[ma_columns[idx].data1]
        end if
      end for
    when "GET"
      -- Clear column types
      call mr_chart.doc.data.types.clear()

      -- Fetch data from Table to Chart
      for idx = 1 to ma_columns.getLength()
        let mr_chart.doc.data.columns[idx,1] = ma_columns[idx].data1
        let mr_chart.doc.data.columns[idx,2] = ma_columns[idx].data2
        let mr_chart.doc.data.columns[idx,3] = ma_columns[idx].data3
        let mr_chart.doc.data.columns[idx,4] = ma_columns[idx].data4
        let mr_chart.doc.data.columns[idx,5] = ma_columns[idx].data5
        let mr_chart.doc.data.columns[idx,6] = ma_columns[idx].data6
        let mr_chart.doc.data.columns[idx,7] = ma_columns[idx].data7

        -- Any column type override?
        if ma_columns[idx].col_type.getLength()
        then
          let mr_chart.doc.data.types[ma_columns[idx].data1] = ma_columns[idx].col_type
        end if
      end for
  end case
      
end function



#
# PRIVATE
#


#
#! combo_List
#

private function combo_List(p_field string, p_list string)

  define
    o_combo ui.ComboBox,
    a_list dynamic array of string,
    idx integer

  -- Get list of items
  call wc_c3chart.Domain(p_list)
    returning a_list

  -- and load up combobox
  let o_combo = ui.ComboBox.forName(p_field)
  for idx = 1 to p_list.getLength()
    call o_combo.addItem(a_list[idx], a_list[idx])
  end for
   
end function


#
#! random_Data
#
private function random_Data(p_max integer)

  return security.RandomGenerator.CreateRandomNumber() mod p_max
  
end function



#
# Dialogs
#

#
#! chart_Head
#
private dialog chart_Head()
    
    input
        mr_chart.title,
        mr_chart.narrative,
        mr_chart.showfocus,
        mr_chart.doc.axis.rotated,
        mr_chart.doc.axis.x.type,
        mr_chart.doc.axis.x.label,
        mr_chart.doc.axis.y.type,
        mr_chart.doc.axis.y.label,
        mr_chart.doc.grid.x.show,
        mr_chart.doc.grid.y.show,
        mr_chart.doc.legend.show,
        mr_chart.doc.legend.position,
        mr_chart.doc.tooltip.show,
        mr_chart.doc.tooltip.grouped,
        mr_chart.doc.tooltip.format,
        m_chart
      from
        hdr.*,
        axes.*,
        p_chart
      attributes(without defaults)
      on change title, narrative, showfocus, rotated, x_type, x_label, y_type, y_label, x_grid, y_grid,
        legend_show, legend_position, tooltip_show, tooltip_grouped, tooltip_format
        call wc_c3chart.Set(mr_chart.*)
    end input
    
end dialog


#
#! chart_Data
#
private dialog chart_Data()

  input
      mr_chart.doc.data.type,
      mr_chart.doc.data.x,
      mr_chart.doc.data.xFormat,
      mr_chart.doc.data.y,
      mr_chart.doc.data.xFormat
    from
      data.*
    attributes(without defaults)
    on change type, x, y, xFormat, yFormat
        call wc_c3chart.Set(mr_chart.*)
  end input
  
end dialog


#
#! chart_Columns: %%% This should be dynamic
#
private dialog chart_Columns()
    
  input array ma_columns
    from columns.*
    attributes(without defaults)
    on change col_type, data1, data2, data3, data4, data5, data6, data7
      call Table("GET")
      call wc_c3chart.Set(mr_chart.*)
  end input
  
end dialog




