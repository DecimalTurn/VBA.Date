Attribute VB_Name = "DateCall"
Option Compare Database
Option Explicit
'
' DateCall
' Version 1.2.0
'
' (c) Gustav Brock, Cactus Data ApS, CPH
' https://github.com/GustavBrock/VBA.Date
'
' Callback functions for use in forms.
'
' License: MIT (http://opensource.org/licenses/mit-license.php)
'
' Required references:
'   None
'
' Required modules:
'   DateBase
'   DateFind

' Common constants.

    ' NB: ------------------------------------------------------
    ' A callback function may accept a larger value, but will not
    ' list more rows than MaximumRowCount.
    ' In any case, do limit the row count to as few as possible,
    ' or selecting a value may take an unacceptable time.
    ' ----------------------------------------------------------
    ' Maximum count of rows.
    Public Const MaximumRowCount        As Long = 65534
    ' Minimum count of rows.
    Public Const MinimumRowCount        As Long = 1
    
    ' Default column width.
    Private Const DefaultColumnWidth    As Integer = -1
    ' Hidden column width.
    Private Const HiddenColumnWidth     As Integer = 0
    ' Non-hidden, yet invisible column width.
    Private Const MinimalColumnWidth    As Integer = 1
    ' Undocumented normally not used constant.
    Private Const acLBOpenAsVariant     As Integer = 2
'

' Callback function to list the friendly names of
' intervals, native as well as extended.
'
' Example for retrieval of selected value:
'
'   Dim Interval As String
'   Interval = Me!ControlName.Value
'
' Typical settings for combobox or listbox:
'
'   ControlSource:  Bound or unbound
'   RowSource:      Leave empty
'   RowSourceType:  CallIntervals
'   BoundColumn:    1
'   LimitToList:    Yes
'   AllowEditing:   No
'   Format:         None
'   ColumnCount:    Don't care. Will be set by the function
'   ColumnWidths:   Don't care. Will be overridden by the function
'
' 2021-01-07. Cactus Data ApS, CPH.
'
Public Function CallIntervals( _
    ByRef Control As Control, _
    ByVal Id As Long, _
    ByVal Row As Long, _
    ByVal Column As Variant, _
    ByVal Code As Integer) _
    As Variant

    ' Adjustable constants.
    '
    ' Left margin of combobox to align the values on list with the formatted value displayed.
    ' Empiric value.
    Const LeftMargin    As Integer = 23
    
    ' Fixed constants.
    '
    ' Count of columns in the control.
    Const ColumnCount   As Integer = 2
    
    Static ColumnWidth(0 To ColumnCount - 1) As Integer
    Static RowCount     As Integer
    
    Dim Value           As Variant
    
    Select Case Code
        Case acLBInitialize
            ' Control settings.
            Control.ColumnCount = ColumnCount   ' Set the colum count of the control.
            ColumnWidth(0) = MinimalColumnWidth ' Truncate the bound (value) column.
            ColumnWidth(1) = DefaultColumnWidth ' Set the width of the display column to the default width.
            If Control.ControlType = acComboBox Then
                Control.LeftMargin = LeftMargin ' Adjust left margin of combobox.
            End If
            
            ' Value settings.
            RowCount = 1 + DtInterval.[_Last]   ' Count of rows to display.
            
            ' Initialize.
            Value = True                        ' True to initialize.
        Case acLBOpen
            Value = Timer                       ' Autogenerated unique ID.
        Case acLBGetRowCount                    ' Get count of rows.
            Value = RowCount                    ' Set count of rows.
        Case acLBGetColumnCount                 ' Get count of columns.
            Value = ColumnCount                 ' Set count of columns.
        Case acLBGetColumnWidth                 ' Get the column width.
            Value = ColumnWidth(Column)         ' Use preset column widths.
        Case acLBGetValue                       ' Get the data for each row.
            Value = IntervalSetting(Row, True)
        Case acLBGetFormat                      ' Format the data.
            ' none.                             ' Apply the value or the display format.
        Case acLBClose                          ' Do something when the form recalculates or closes.
            ' no-op.
        Case acLBEnd                            ' Do something more when the form recalculates or closes.
            ' no-op.
    End Select
    
    ' Return Value.
    CallIntervals = Value

End Function

' Callback function to list the weekday names of a week.
' The selected value will be the date of the weekday in the current week.
' The displayed values will be those of WeekdayName(DayOfWeek, False, vbSunday).
'
' Example for retrieval of selected value:
'
'   Dim DateOfWeek As Date
'   DateOfWeek = Me!ControlName.Value
'
' Typical settings for combobox or listbox:
'
'   ControlSource:  Bound or unbound
'   RowSource:      Leave empty
'   RowSourceType:  CallThisWeekDates
'   BoundColumn:    1
'   LimitToList:    Yes
'   AllowEditing:   No
'   Format:         None
'   ColumnCount:    Don't care. Will be set by the function
'   ColumnWidths:   Don't care. Will be overridden by the function
'
' 2021-02-16. Cactus Data ApS, CPH.
'
Public Function CallThisWeekDates( _
    ByRef Control As Control, _
    ByVal Id As Long, _
    ByVal Row As Long, _
    ByVal Column As Variant, _
    ByVal Code As Integer) _
    As Variant

    ' Adjustable constants.
    '
    ' Left margin of combobox to align the values on list with the formatted value displayed.
    ' Empiric value.
    Const LeftMargin        As Integer = 23
    
    ' Fixed constants.
    '
    ' Count of rows to display.
    Const RowCount          As Long = DaysPerWeek
    ' Count of columns in the control.
    Const ColumnCount       As Integer = 2
    
    Static ColumnWidth(0 To ColumnCount - 1) As Integer
    Static FirstDateOfWeek  As Date
    
    Dim DateOfWeek          As Date
    Dim Value               As Variant
    
    Select Case Code
        Case acLBInitialize
            ' Control settings.
            Control.ColumnCount = ColumnCount   ' Set the colum count of the control.
            ColumnWidth(0) = HiddenColumnWidth  ' Hide the bound (value) column.
            ColumnWidth(1) = DefaultColumnWidth ' Set the width of the display column to the default width.
            If Control.ControlType = acComboBox Then
                Control.LeftMargin = LeftMargin ' Adjust left margin of combobox.
            End If
            
            ' Value settings.
                                                ' First date of the week as to the system settings.
            FirstDateOfWeek = DateThisWeekPrimo(Date, vbUseSystemDayOfWeek)
            
            ' Initialize.
            Value = True                        ' True to initialize.
        Case acLBOpen
            Value = Timer                       ' Autogenerated unique ID.
        Case acLBGetRowCount                    ' Get count of rows.
            Value = RowCount                    ' Set count of rows.
        Case acLBGetColumnCount                 ' Get count of columns.
            Value = ColumnCount                 ' Set count of columns.
        Case acLBGetColumnWidth                 ' Get the column width.
            Value = ColumnWidth(Column)         ' Use preset column widths.
        Case acLBGetValue                       ' Get the data for each row.
            DateOfWeek = DateAdd("d", Row, FirstDateOfWeek)
            If Column = 0 Then
                ' Return date of weekday.
                Value = DateOfWeek
            Else
                ' Return friendly name for display.
                Value = StrConv(Format(DateOfWeek, "dddd"), vbProperCase)
            End If
        Case acLBGetFormat                      ' Format the data.
            ' N/A                               ' Apply the value or the display format.
        Case acLBClose                          ' Do something when the form recalculates or closes.
            ' no-op.
        Case acLBEnd                            ' Do something more when the form recalculates or closes.
            ' no-op.
    End Select
    
    ' Return Value.
    CallThisWeekDates = Value

End Function

' Callback function to list the ultimo dates of
' each month for a count of years.
'
' Example for retrieval of selected value:
'
'   Dim SelectedDate As Date
'   SelectedDate = Me!ControlName.Value
'
' Typical settings for combobox or listbox:
'
'   ControlSource:  Bound or unbound
'   RowSource:      Leave empty
'   RowSourceType:  CallUltimoMonthDates
'   BoundColumn:    1
'   LimitToList:    Yes
'   AllowEditing:   No
'   Format:         A valid format for date values
'   ColumnCount:    Don't care. Will be set by the function
'   ColumnWidths:   Don't care. Will be overridden by the function
'
' 2021-03-01. Cactus Data ApS, CPH.
'
Public Function CallUltimoMonthDates( _
    ByRef Control As Control, _
    ByVal Id As Long, _
    ByVal Row As Long, _
    ByVal Column As Variant, _
    ByVal Code As Integer) _
    As Variant

    ' Adjustable constants.
    '
    ' Count of years to list months.
    Const Years         As Integer = 1
    ' Format for the display column in a listbox.
    Const ListboxFormat As String = "Short Date"
    ' Left margin of combobox to align the values on list with the formatted value displayed.
    ' Empiric value.
    Const LeftMargin    As Integer = 23
    
    ' Fixed constants.
    '
    ' Day value for ultimo of previous month.
    Const UltimoDay     As Integer = 0
    ' Count of columns in the control.
    Const ColumnCount   As Integer = 2
    
    ' Function constants.
    '
    ' Control IDs.
    Const DefaultId     As Long = -1
    Const ResetId       As Long = 0
    Const ActionId      As Long = 1
    ' Setting IDs.
    Const StartDateId   As Long = 1
    Const RowCountId    As Long = 2
    Const FormatId      As Long = 3
    
    Static ColumnWidth(0 To ColumnCount - 1) As Integer
    Static Format(0 To ColumnCount - 1)      As String
    Static RowCount     As Long
    Static Initialized  As Boolean
    
    Static Year         As Integer
    Static Month        As Integer
    
    Dim Start           As Date
    Dim Value           As Variant
    
    Select Case Code
        Case acLBInitialize
            ' Control settings.
            Control.ColumnCount = ColumnCount   ' Set the colum count of the control.
            ColumnWidth(0) = HiddenColumnWidth  ' Hide the bound (value) column.
            ColumnWidth(1) = DefaultColumnWidth ' Set the width of the display column to the default width.
            
            ' Initialize.
            Value = True                        ' True to initialize.
        Case acLBOpenAsVariant
            ' Id:       Action.
            ' Row:      Parameter id.
            ' Column:   Parameter value.
            Select Case Id
                Case DefaultId                              ' Default call.
                    If Not Initialized Then
                        Start = Date
                        Year = VBA.Year(Start)              ' Year of the first month to list.
                        Month = VBA.Month(Start) + 1        ' Month of the second month to list.
                        RowCount = Years * MonthsPerYear    ' Count of rows to display.
                        If Control.ControlType = acComboBox Then
                            Format(1) = Control.Format      ' Retrieve the display format from the combobox's Format property.
                            Control.LeftMargin = LeftMargin ' Adjust left margin of combobox.
                        Else
                            Format(1) = ListboxFormat       ' Set the display format for the listbox.
                        End If
                        Initialized = True
                    End If
                Case ResetId                                ' Custom call. Ignore custom settings for the current control.
                    Initialized = False
                Case ActionId                               ' Custom call. Set one optional value.
                    ' Row:      The id of the parameter to adjust.
                    ' Column:   The value of the parameter.
                    Select Case Row
                        Case StartDateId                    ' Start date.
                            If VarType(Column) = vbDate Then
                                Start = Column
                            End If
                            Year = VBA.Year(Start)          ' Year of the first month to list.
                            Month = VBA.Month(Start) + 1    ' Month of the second month to list.
                        Case RowCountId                     ' Count of weeks to list.
                            RowCount = Column
                        Case FormatId                       ' Format for display.
                            If VarType(Column) = vbString Then
                                Format(1) = Column
                            End If
                    End Select
            End Select
            
            ' Do not return a value.
        Case acLBOpen
            ' Value will be rounded to integer, so multiply by 100. Howeever, a Single
            ' (as returned by Timer) will be rounded to even, so convert the value to Long.
            Value = CLng(Timer * 100)           ' Autogenerated unique ID.
        Case acLBGetRowCount                    ' Get count of rows.
            Value = RowCount                    ' Set count of rows.
        Case acLBGetColumnCount                 ' Get count of columns.
            Value = ColumnCount                 ' Set count of columns.
        Case acLBGetColumnWidth                 ' Get the column width.
            Value = ColumnWidth(Column)         ' Use preset column widths.
        Case acLBGetValue                       ' Get the data for each row.
            ' Split rows in years and months to prevent overload of months.
            Value = DateSerial(Year + Row \ 12, Month + Row Mod 12, UltimoDay)
        Case acLBGetFormat                      ' Format the data.
            If Column = 1 Then
                Value = Format(Column)          ' Apply the display format.
            End If
        Case acLBClose                          ' Do something when the form recalculates or closes.
            ' no-op.
        Case acLBEnd                            ' Do something more when the form recalculates or closes.
            ' no-op.
    End Select
    
    ' Return Value.
    CallUltimoMonthDates = Value

End Function

' Callback function to list the dates of a weekday for a count of weeks.
' By default, the first day of the week according to the system settings
' is listed from the current date for twelve weeks.
'
' Optionally, any weekday, any start date, and any count of weeks can be
' set by the function ConfigWeekdayDates.
' Multiple controls - even a mix of comboboxes and listboxes - can be
' controlled simultaneously with individual settings.
'
' The format of the listed dates are determined by the controls' Format
' properties.
'
' Example for retrieval of selected value:
'
'   Dim SelectedDate As Date
'   SelectedDate = Me!ControlName.Value
'
' Typical settings for combobox or listbox:
'
'   ControlSource:  Bound or unbound
'   RowSource:      Leave empty
'   RowSourceType:  CallWeekdayDates
'   BoundColumn:    1
'   LimitToList:    Yes
'   AllowEditing:   No
'   ColumnCount:    Don't care. Will be set by the function
'   ColumnWidths:   Don't care. Will be overridden by the function
'   ListCount:      Don't care. Will be overridden by the function (ComboBox only)
'   Format:         Optional. A valid format for date values (ComboBox only)
'   Tag:            Optional. 1 to 255.
'                   Count of rows listed. If empty or 0, DefaultWeekCount is used
'
' 2021-03-01. Gustav Brock. Cactus Data ApS, CPH.
'
Public Function CallWeekdayDates( _
    ByRef Control As Control, _
    ByVal Id As Long, _
    ByVal Row As Long, _
    ByVal Column As Variant, _
    ByVal Code As Integer) _
    As Variant
    
    ' Adjustable constants.
    '
    ' Initial count of weeks to list.
    ' Fixed for a listbox. A combobox can be reconfigured with function ConfigWeekdayDates.
    ' Will be overridden by a value specified in property Tag.
    Const DefaultWeekCount      As Integer = 16
    ' Format for the display column in a listbox.
    Const ListboxFormat         As String = "Short Date"
    ' Left margin of combobox to align the values on list with the formatted value displayed.
    ' Empiric value.
    Const LeftMargin            As Integer = 23
    
    ' Fixed constants.
    '
    ' Count of columns in the control.
    Const ColumnCount           As Integer = 2
    
    ' Function constants.
    '
    ' Array constants.
    Const ControlOption         As Integer = 0
    Const ApplyOption           As Integer = 1
    Const WeekdayOption         As Integer = 2
    Const StartDateOption       As Integer = 3
    Const RowCountOption        As Integer = 4
    Const FormatOption          As Integer = 5
    Const ControlDimension      As Integer = 2
    ' Control IDs.
    Const DefaultId             As Long = -1
    Const ResetId               As Long = 0
    Const ActionId              As Long = 1
    ' Setting IDs.
    Const DayOfWeekId           As Long = 1
    Const StartDateId           As Long = 2
    Const RowCountId            As Long = 3
    Const FormatId              As Long = 4
    
    Static ColumnWidth(0 To ColumnCount - 1)    As Integer
    Static DateFormat           As String
    Static OptionalValues()     As Variant
    Static Initialized          As Boolean
    
    Dim ControlName             As String
    Dim ControlIndex            As Integer
    Dim StartDate               As Date
    Dim FirstDate               As Date
    Dim DayOfWeek               As VbDayOfWeek
    Dim RowCount                As Integer
    Dim Value                   As Variant
    
    Select Case Code
        Case acLBInitialize
            ' Control settings.
            Control.ColumnCount = ColumnCount           ' Set the colum count of the control.
            Control.ColumnWidths = MinimalColumnWidth   ' Record width of first column. This is used for a requery.
            ColumnWidth(0) = HiddenColumnWidth          ' Hide the bound (value) column.
            ColumnWidth(1) = DefaultColumnWidth         ' Set the width of the display column to the default width.
            If Control.ControlType = acComboBox Then
                ' Set the date format later.            ' Retrieve the display format from the combobox's Format property.
                Control.LeftMargin = LeftMargin         ' Adjust left margin of combobox.
            Else
                DateFormat = ListboxFormat              ' Set the display format for the listbox.
            End If
            
            If Not Initialized Then
                ' Array for optional values has not been dimmed in this session.
                ReDim OptionalValues(ControlOption To FormatOption, 0 To 0)
                Initialized = True
            End If
            
            ' Initialize.
            Value = True                                ' True to initialize.
        Case acLBOpenAsVariant
            ControlName = Control.Name
            ' Find or create the index of the current control.
            For ControlIndex = LBound(OptionalValues, ControlDimension) To UBound(OptionalValues, ControlDimension)
                If OptionalValues(ControlOption, ControlIndex) = ControlName Then
                    Exit For
                End If
            Next
            If ControlIndex > UBound(OptionalValues, ControlDimension) Then
                ' Add yet a control.
                ReDim Preserve OptionalValues(ControlOption To FormatOption, 0 To ControlIndex)
                OptionalValues(ControlOption, ControlIndex) = ControlName
            End If
            
            ' Id:       Action.
            ' Row:      Parameter id.
            ' Column:   Parameter value.
            Select Case Id
                Case DefaultId                          ' Default call.
                    If OptionalValues(ApplyOption, ControlIndex) = False Then
                        ' Apply initial/default settings.
                        OptionalValues(ControlOption, ControlIndex) = ControlName
                        OptionalValues(ApplyOption, ControlIndex) = True
                        ' Use system's first day of week.
                        OptionalValues(WeekdayOption, ControlIndex) = SystemDayOfWeek
                        OptionalValues(StartDateOption, ControlIndex) = Date
                        RowCount = Val(Control.Tag)
                        If RowCount = 0 Then
                            RowCount = DefaultWeekCount
                        End If
                        OptionalValues(RowCountOption, ControlIndex) = RowCount
                        ' If this is a combobox, retrieve the default format from its Format property.
                        If Control.ControlType = acComboBox Then
                            DateFormat = Control.Format
                        End If
                        OptionalValues(FormatOption, ControlIndex) = DateFormat
                    End If
                Case ResetId                            ' Custom call. Ignore custom settings for the current control.
                    OptionalValues(ApplyOption, ControlIndex) = False
                Case ActionId                           ' Custom call. Set one optional value.
                    ' Row:      The id of the parameter to adjust.
                    ' Column:   The value of the parameter.
                    Select Case Row
                        Case DayOfWeekId                ' Day of week.
                            OptionalValues(WeekdayOption, ControlIndex) = Column
                        Case StartDateId                ' Start date.
                            If VarType(Column) = vbDate Then
                                OptionalValues(StartDateOption, ControlIndex) = Column
                            End If
                        Case RowCountId                 ' Count of weeks to list.
                            OptionalValues(RowCountOption, ControlIndex) = Column
                        Case FormatId                   ' Format for display.
                            If VarType(Column) = vbString Then
                                OptionalValues(FormatOption, ControlIndex) = Column
                            End If
                    End Select
            End Select
            
            ' Do not return a value.
        Case acLBOpen
            ' Value will be rounded to integer, so multiply by 100. Howeever, a Single
            ' (as returned by Timer) will be rounded to even, so convert the value to Long.
            Value = CLng(Timer * 100)                   ' Autogenerated unique ID.
        Case acLBGetRowCount                            ' Get count of rows.
            ControlName = Control.Name
            ' Find the index of the current control.
            For ControlIndex = LBound(OptionalValues, ControlDimension) To UBound(OptionalValues, ControlDimension)
                If OptionalValues(ControlOption, ControlIndex) = ControlName Then
                    Exit For
                End If
            Next
            ' Retrieve current setting.
            RowCount = OptionalValues(RowCountOption, ControlIndex)
            Value = RowCount                            ' Set count of rows.
        Case acLBGetColumnCount                         ' Get count of columns.
            Value = ColumnCount                         ' Set count of columns.
        Case acLBGetColumnWidth                         ' Get the column width.
            Value = ColumnWidth(Column)                 ' Use preset column widths.
        Case acLBGetValue                               ' Get the data for each row.
            ControlName = Control.Name
            ' Find the index of the current control.
            For ControlIndex = LBound(OptionalValues, ControlDimension) To UBound(OptionalValues, ControlDimension)
                If OptionalValues(ControlOption, ControlIndex) = ControlName Then
                    Exit For
                End If
            Next
            ' Retrieve current settings.
            StartDate = OptionalValues(StartDateOption, ControlIndex)
            DayOfWeek = OptionalValues(WeekdayOption, ControlIndex)
            ' Retrieve and save for this ControlIndex the format for the
            ' next call of the function which will have Code = acLBGetFormat.
            DateFormat = OptionalValues(FormatOption, ControlIndex)
            ' Calculate the earliest date later than or equal to the start date.
            FirstDate = DateNextWeekday(DateAdd("d", -1, StartDate), DayOfWeek)
            ' Calculate the date for this row.
            Value = DateAdd("ww", Row, FirstDate)
        Case acLBGetFormat                              ' Format the data.
            If Column = 1 Then
                Value = DateFormat                      ' Apply the value or the display format.
            End If
        Case acLBClose                                  ' Do something when the form recalculates or closes.
            ' no-op.
        Case acLBEnd                                    ' Do something more when the form recalculates or closes.
            ' no-op.
    End Select

    ' Return Value.
    CallWeekdayDates = Value

End Function

' Callback function to list the weekday names of a week.
' The selected value will be a value of enum VbDayOfWeek (Long).
' The displayed values will be those of WeekdayName(DayOfWeek, False, vbSunday).
'
' Example for retrieval of selected value:
'
'   Dim DayOfWeek As VbDayOfWeek
'   DayOfWeek = Me!ControlName.Value
'
' Typical settings for combobox or listbox:
'
'   ControlSource:  Bound or unbound
'   RowSource:      Leave empty
'   RowSourceType:  CallWeekdays
'   BoundColumn:    1
'   LimitToList:    Yes
'   AllowEditing:   No
'   Format:         None
'   ColumnCount:    Don't care. Will be set by the function
'   ColumnWidths:   Don't care. Will be overridden by the function
'
' 2021-02-19. Cactus Data ApS, CPH.
'
Public Function CallWeekdays( _
    ByRef Control As Control, _
    ByVal Id As Long, _
    ByVal Row As Long, _
    ByVal Column As Variant, _
    ByVal Code As Integer) _
    As Variant

    ' Adjustable constants.
    '
    ' Left margin of combobox to align the values on list with the formatted value displayed.
    ' Empiric value.
    Const LeftMargin        As Integer = 23
    
    ' Fixed constants.
    '
    ' Count of rows to display.
    Const RowCount          As Long = DaysPerWeek
    ' Count of columns in the control.
    Const ColumnCount       As Integer = 2
    
    Static ColumnWidth(0 To ColumnCount - 1) As Integer
    Static FirstDayOfWeek   As VbDayOfWeek
    
    Dim DayOfWeek           As VbDayOfWeek
    Dim Value               As Variant
    
    Select Case Code
        Case acLBInitialize
            ' Control settings.
            Control.ColumnCount = ColumnCount   ' Set the colum count of the control.
            ColumnWidth(0) = HiddenColumnWidth  ' Hide the bound (value) column.
            ColumnWidth(1) = DefaultColumnWidth ' Set the width of the display column to the default width.
            If Control.ControlType = acComboBox Then
                Control.LeftMargin = LeftMargin ' Adjust left margin of combobox.
            End If
            
            ' Value settings.
            FirstDayOfWeek = SystemDayOfWeek    ' First day in the week as to the system settings.
            
            ' Initialize.
            Value = True                        ' True to initialize.
        Case acLBOpen
            Value = Timer                       ' Autogenerated unique ID.
        Case acLBGetRowCount                    ' Get count of rows.
            Value = RowCount                    ' Set count of rows.
        Case acLBGetColumnCount                 ' Get count of columns.
            Value = ColumnCount                 ' Set count of columns.
        Case acLBGetColumnWidth                 ' Get the column width.
            Value = ColumnWidth(Column)         ' Use preset column widths.
        Case acLBGetValue                       ' Get the data for each row.
            DayOfWeek = (FirstDayOfWeek + Row - 1) Mod DaysPerWeek + 1
            If Column = 0 Then
                ' Return weekday value.
                Value = DayOfWeek
            Else
                ' Return friendly name for display.
                Value = StrConv(WeekdayName(DayOfWeek, False, vbSunday), vbProperCase)
            End If
        Case acLBGetFormat                      ' Format the data.
            ' N/A                               ' Apply the value or the display format.
        Case acLBClose                          ' Do something when the form recalculates or closes.
            ' no-op.
        Case acLBEnd                            ' Do something more when the form recalculates or closes.
            ' no-op.
    End Select
    
    ' Return Value.
    CallWeekdays = Value

End Function

' Set custom parameters for a ComboBox or a ListBox having the function
' CallUltimoMonthDates as RowsourceType.
'
' Usage, where the parameter Object is a ComboBox or a ListBox object:
'
'   Set start date of list:
'   ConfigUltimoMonthDates Object, , #1/1/2020#
'
'   Set count of dates to list (for ComboBox only, ignoreded for ListBox):
'   ConfigUltimoMonthDates Object, , , 10
'
'   Set all parameters:
'   ConfigUltimoMonthDates Object, #4/1/2000#, 18
'
'   Reset all parameters to default settings.
'   NB: Could (should) be called when unloading the form:
'   ConfigUltimoMonthDates Object
'
' 2021-03-01. Cactus Data ApS, CPH.
'
Public Sub ConfigUltimoMonthDates( _
    ByRef Control As Control, _
    Optional ByVal StartDate As Date, _
    Optional ByVal RowCount As Long, _
    Optional ByVal Format As String)
    
    Const FunctionName  As String = "CallUltimoMonthDates"
    Const NoOpValue     As Long = 0
    Const DefaultId     As Long = -1
    Const ResetId       As Long = 0
    Const ActionId      As Long = 1
    Const StartDateId   As Long = 1
    Const RowCountId    As Long = 2
    Const FormatId      As Long = 3
    
    Dim ControlType     As AcControlType
    Dim SetValue        As Boolean
    
    If Not Control Is Nothing Then
        ControlType = Control.ControlType
        If ControlType = acListBox Or ControlType = acComboBox Then
            If Control.RowSourceType = FunctionName Then
                If RowCount <> NoOpValue Then
                    If Control.ControlType = acListBox Then
                        ' Setting of row count not supported.
                        RowCount = NoOpValue
                    End If
                End If
                
                ' Make sure, that this control has called the callback function to be initialized.
                ' That may not be the case, if this configuration function is called during form loading.
                Application.Run FunctionName, Control, DefaultId, NoOpValue, NoOpValue, acLBOpenAsVariant
                
                ' Set parameter(s) and run the function by its name.
                If DateDiff("d", StartDate, #12:00:00 AM#) <> 0 Then
                    Application.Run FunctionName, Control, ActionId, StartDateId, DateValue(StartDate), acLBOpenAsVariant
                    SetValue = True
                End If
                If RowCount > 0 Then
                    Application.Run FunctionName, Control, ActionId, RowCountId, RowCount, acLBOpenAsVariant
                    SetValue = True
                End If
                If Format <> "" Then
                    Application.Run FunctionName, Control, ActionId, FormatId, Format, acLBOpenAsVariant
                    SetValue = True
                End If
                If Not SetValue = True Then
                    ' Reset to default values.
                    Application.Run FunctionName, Control, ResetId, NoOpValue, NoOpValue, acLBOpenAsVariant
                End If
                    
                ' Apply settings.
                Application.Run FunctionName, Control, DefaultId, NoOpValue, NoOpValue, acLBOpenAsVariant
                ' Requery control.
                Control.ColumnWidths = Control.ColumnWidths
            End If
        End If
    End If
    
End Sub

' Set custom parameters for a ComboBox or a ListBox having the function
' CallWeekdayDates as RowsourceType.
'
' Usage, where the parameter Object is a ComboBox or a ListBox object:
'
'   Set weekday to list:
'   ConfigWeekdayDates Object, vbFriday
'
'   Set start date of list:
'   ConfigWeekdayDates Object, , #1/1/2020#
'
'   Set count of dates to list (for ComboBox only, ignoreded for ListBox):
'   ConfigWeekdayDates Object, , , 10
'
'   Set all parameters:
'   ConfigWeekdayDates Object, vbTuesday, #4/1/2000#, 16
'
'   Reset all parameters to default settings.
'   NB: Could (should) be called when unloading the form:
'   ConfigWeekdayDates Object
'
' 2021-03-01. Cactus Data ApS, CPH.
'
Public Sub ConfigWeekdayDates( _
    ByRef Control As Control, _
    Optional ByVal DayOfWeek As VbDayOfWeek, _
    Optional ByVal StartDate As Date, _
    Optional ByVal RowCount As Long, _
    Optional ByVal Format As String)
    
    Const FunctionName  As String = "CallWeekdayDates"
    Const NoOpValue     As Long = 0
    Const DefaultId     As Long = -1
    Const ResetId       As Long = 0
    Const ActionId      As Long = 1
    Const DayOfWeekId   As Long = 1
    Const StartDateId   As Long = 2
    Const RowCountId    As Long = 3
    Const FormatId      As Long = 4
    
    Dim ControlType     As AcControlType
    Dim SetValue        As Boolean
    
    If Not Control Is Nothing Then
        ControlType = Control.ControlType
        If ControlType = acListBox Or ControlType = acComboBox Then
            If Control.RowSourceType = FunctionName Then
                If RowCount <> NoOpValue Then
                    If Control.ControlType = acListBox Then
                        ' Setting of row count not supported.
                        RowCount = NoOpValue
                    End If
                End If
                
                ' Make sure, that this control has called the callback function to be initialized.
                ' That may not be the case, if this configuration function is called during form loading.
                Application.Run FunctionName, Control, DefaultId, NoOpValue, NoOpValue, acLBOpenAsVariant
                
                ' Set parameter(s) and run the function by its name.
                If DayOfWeek > vbUseSystemDayOfWeek Then
                    Application.Run FunctionName, Control, ActionId, DayOfWeekId, DayOfWeek, acLBOpenAsVariant
                    SetValue = True
                End If
                If DateDiff("d", StartDate, #12:00:00 AM#) <> 0 Then
                    Application.Run FunctionName, Control, ActionId, StartDateId, DateValue(StartDate), acLBOpenAsVariant
                    SetValue = True
                End If
                If RowCount > 0 Then
                    Application.Run FunctionName, Control, ActionId, RowCountId, RowCount, acLBOpenAsVariant
                    SetValue = True
                End If
                If Format <> "" Then
                    Application.Run FunctionName, Control, ActionId, FormatId, Format, acLBOpenAsVariant
                    SetValue = True
                End If
                If Not SetValue = True Then
                    ' Reset to default values.
                    Application.Run FunctionName, Control, ResetId, NoOpValue, NoOpValue, acLBOpenAsVariant
                End If
                    
                ' Apply settings.
                Application.Run FunctionName, Control, DefaultId, NoOpValue, NoOpValue, acLBOpenAsVariant
                ' Requery control.
                Control.ColumnWidths = Control.ColumnWidths
            End If
        End If
    End If
    
End Sub

