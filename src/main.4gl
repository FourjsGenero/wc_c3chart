#
# main.4gl  Main for all unit tests
#


import FGL fgldialog
import FGL test_chart

private define
 m_menu boolean


#
# Main: Unit Test
#

main

  define
    p_test string

  let p_test = NVL(ARG_VAL(1), "c3chart")
  call Run(p_test)
  
end main


#
#! Setup
#
private function Setup()

  if not m_menu
  then
    close window screen
  end if
  
end function


#
#! Teardown
#
private function Teardown()
end function


#
#! Menu
#
private function Menu()

  let m_menu = TRUE
  
  menu "Menu"
    on action chart attribute(text="c3chart")
      call Run("test")
    on action close
      exit menu
  end menu
end function


#
#! Run
#
public function Run(p_request)

  define
    p_request string

  case p_request
    when "c3chart"
      call Setup()
      call test_chart.Test()
    when "MENU"
      call Menu()
  end case
    
end function


