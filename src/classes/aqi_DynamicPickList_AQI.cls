global class aqi_DynamicPickList_AQI extends VisualEditor.DynamicPickList{

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('none', 'none');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        myValues.addRow(new VisualEditor.DataRow('none','none'));
        Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
		Map<String,String>  indexLabels = aqi_Ctrl.getindexApiNameToLabel();

        for(String k :indexValues.keySet() ){
            if(k != 'Possible_Points__c' && indexLabels.containsKey(k)){
    			myValues.addRow(new VisualEditor.DataRow( indexLabels.get(k),k));
            }
        }

        return myValues;
    }
}
