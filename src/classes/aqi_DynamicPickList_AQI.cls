/**
* @author Altimetrik
* @description
* started on January 2018
* This class its responsible of return the dynamic picklist for aqi and the default value
**/
global class aqi_DynamicPickList_AQI extends VisualEditor.DynamicPickList{

    // Methods

    /*
    * @description
    *	retrieve the default value
    * @params
    *	N/A
    * @return
    *	Return the default value
    */
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('none', 'none');
        return defaultValue;
    }

    /*
    * @description
    *	retrieve the picklist values
    * @params
    *	N/A
    * @return
    *	Return the picklist values
    */
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(new VisualEditor.DataRow('none','none'));
        Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
		Map<String,String>  indexLabels = aqi_Ctrl.getindexApiNameToLabel();
        for (String k :indexValues.keySet()) {
            if ((!k.contains('Possible_Points__c')) && indexLabels.containsKey(k)) {
    			myValues.addRow(new VisualEditor.DataRow( indexLabels.get(k),k));
            }
        }
        return myValues;
    }
}
