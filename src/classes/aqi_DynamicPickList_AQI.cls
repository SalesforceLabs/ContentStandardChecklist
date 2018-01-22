global class aqi_DynamicPickList_AQI extends VisualEditor.DynamicPickList{

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('none', 'none');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        
        myValues.addRow(new VisualEditor.DataRow('none','none'));
        Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
        for(String k :indexValues.keySet() ){
			myValues.addRow(new VisualEditor.DataRow(k, k));
        }
        
        return myValues;
    }
}