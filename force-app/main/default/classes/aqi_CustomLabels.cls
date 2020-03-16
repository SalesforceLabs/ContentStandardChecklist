/**
* @author Altimetrik
* @description
*    started on 13/03/2020
*    Custom labels reference to be included in package
**/
public with sharing class aqi_CustomLabels {
    
    public static Boolean getLabels() {
        Boolean success = true;
        try {
            //Abstract Lightning Component
            String undetermined_error = Label.Undetermined_error;
            String error_occurred_in_Apex_call_error = Label.Error_occurred_in_Apex_call_error;
            String an_error_occurred_error = Label.An_error_occurred_error;

            //Article Quality Index Lightning Component
            String article_Quality_Index_title = Label.Article_Quality_Index_title;
            String score = Label.Score;
            String apply_button = Label.Apply_button;
            String aqi_Criteria_title = Label.AQI_Criteria_title;
            String no_fields_message = Label.No_fields_message;
            String article_contributor_label = Label.Article_contributor_label;
            String action_assigned_to_helptext = Label.Action_assigned_to_helptext;
            String action_date_helptext = Label.Action_date_helptext;
            String action_taken_helptext = Label.Action_taken_helptext;
            String internal_notes_helptext = Label.Internal_notes_helptext;
            String select_AQI_first_field_label = Label.Select_AQI_first_field_label;
            String select_AQI_second_field_label = Label.Select_AQI_second_field_label;
            String select_AQI_third_field_label = Label.Select_AQI_third_field_label;
            String select_AQI_fourth_field_label = Label.Select_AQI_fourth_field_label;
            String select_AQI_fifth_field_label = Label.Select_AQI_fifth_field_label;
            String select_AQI_sixth_field_label = Label.Select_AQI_sixth_field_label;
            String select_AQI_seventh_field_label = Label.Select_AQI_seventh_field_label;
            String select_AQI_eight_field_label = Label.Select_AQI_eight_field_label;
            String select_AQI_ninth_field_label = Label.Select_AQI_ninth_field_label;
            String select_AQI_tenth_field_label = Label.Select_AQI_tenth_field_label;
            String none_defaultValue = Label.None_defaultValue;
            String article_contributor_not_found_error = Label.Article_contributor_not_found_error;
            String article_contributor_not_found_error_message = Label.Article_contributor_not_found_error_message;
            String aqi_Successfully_updated_message = Label.AQI_Successfully_updated_message;
            String aqi_has_been_updated_message = Label.AQI_has_been_updated_message;
            String the_new_score_is_message = Label.The_new_score_is_message;
            String responseMap_empty_message = Label.ResponseMap_empty_message;

            //Related Article Lightning Component
            String related_Article_title = Label.Related_Article_title;
            String view_article_button = Label.View_article_button;
            String language_label = Label.Language_label;
            String article_Number_label = Label.Article_Number_label;
            String article_Publishing_Status_label = Label.Article_Publishing_Status_label;
            String article_Version_label = Label.Article_Version_label;
            String article_Record_Type_label = Label.Article_Record_Type_label;
            String loading_message = Label.Loading_message;
            String warning_message = Label.Warning_message;
            String related_Article_archived_error = Label.Related_Article_archived_error;

            //ArticleQualityIndexCtrl Apex class
            String follow_Up_field_not_retrieved_error = Label.Follow_Up_field_not_retrieved_error;
            String list_of_API_names_empty_error = Label.List_of_API_names_empty_error;
            String article_Id_empty_error = Label.Article_Id_empty_error;
            String none_message = Label.None_message;
            String related_article_not_found_error = Label.Related_article_not_found_error;
            String error_getting_id_of_related_article_error = Label.Error_getting_id_of_related_article_error;

            //Ctrl Apex Class
            String article_has_no_record_type_error = Label.Article_has_no_record_type_error;
            String invalid_Knowledge_Article_error = Label.Invalid_Knowledge_Article_error;
            String article_Type_permissions_error = Label.Article_Type_permissions_error;
            String related_article_is_draft_message = Label.Related_article_is_draft_message;
            String related_article_is_archived_message = Label.Related_article_is_archived_message;
            String specify_coaching_error = Label.Specify_coaching_error;
            String specify_article_version_error = Label.Specify_article_version_error;

            //KnowledgeSearchCtrl Apex class
            String search_criteria_error = Label.Search_criteria_error;
            String article_number_error = Label.Article_number_error;
            String last_Modified_date_invalid_error = Label.Last_Modified_date_invalid_error;
            String first_Published_date_invalid_error = Label.First_Published_date_invalid_error;

            //Detail Visualforce page
            String delete_confirm = Label.Delete_confirm;
            String article_Quality_Index_details_title = Label.Article_Quality_Index_details_title;
            String edit_button = Label.Edit_button;
            String delete_button = Label.Delete_button;
            String information_title = Label.Information_title;
            String owner_label = Label.Owner_label;
            String created_by_label = Label.Created_by_label;
            String follow_Up_details_title = Label.Follow_Up_details_title;
            String related_Article_Details_title = Label.Related_Article_Details_title;
            String related_Article_Current_Details_title = Label.Related_Article_Current_Details_title;
            String article_Created_Date_label = Label.Article_Created_Date_label;
            String article_Created_By_label = Label.Article_Created_By_label;
            String system_Information_title = Label.System_Information_title;
                       
            //Edit Visualforce page
            String save_button = Label.Save_button;
            String cancel_button = Label.Cancel_button;
            
            //KnowledgeSearch Visualforce page
            String create_AQI_title = Label.Create_AQI_title;
            String date_Range_invalid_first_alert = Label.Date_Range_invalid_first_alert;
            String date_Range_invalid_last_alert = Label.Date_Range_invalid_last_alert;
            String display_in_Classic_alert = Label.Display_in_Classic_alert;
            String create_or_Edit_helptext = Label.Create_or_Edit_helptext;
            String search_Knowledge_placeholder = Label.Search_Knowledge_placeholder;
            String search_Article_Number_placeholder = Label.Search_Article_Number_placeholder;
            String search_Created_By_placeholder = Label.Search_Created_By_placeholder;
            String search_Last_Modified_By_placeholder = Label.Search_Last_Modified_By_placeholder;
            String all_picklistValue = Label.All_picklistValue;
            String first_Published_date_from_label = Label.First_Published_date_from_label;
            String last_Modified_date_from_label = Label.Last_Modified_date_from_label;
            String first_Published_date_to_label = Label.First_Published_date_to_label;
            String last_Modified_date_to_label = Label.Last_Modified_date_to_label;
            String search_button = Label.Search_button;
            String new_AQI_helptext = Label.New_AQI_helptext;
            String name_helptext = Label.Name_helptext;
            String title_tableheader = Label.Title_tableheader;
            String account_Name_helptext = Label.Account_Name_helptext;
            String article_Number_tableheader = Label.Article_Number_tableheader;
            String record_Type_tableheader = Label.Record_Type_tableheader;
            String version_tableheader = Label.Version_tableheader;
            String summary_tableheader = Label.Summary_tableheader;
            String validation_Status_tableheader = Label.Validation_Status_tableheader;
            String last_Modified_Date_helptext = Label.Last_Modified_Date_helptext;
            String last_Modified_tableheader = Label.Last_Modified_tableheader;
            String first_Published_Date_helptext = Label.First_Published_Date_helptext;
            String first_Published_tableheader = Label.First_Published_tableheader;
            String last_Modified_By_tableheader = Label.Last_Modified_By_tableheader;
            String created_By_tableheader = Label.Created_By_tableheader;
            String has_AQI_helptext = Label.Has_AQI_helptext;
            String aqi_tableheader = Label.AQI_tableheader;
            String first_button = Label.First_button;
            String previous_button = Label.Previous_button;
            String next_button = Label.Next_button;
            String no_records_to_display_message = Label.No_records_to_display_message;

            //Setup Visualforce page
            String application_Setup_title = Label.Application_Setup_title;
            String aqi_Section_title = Label.AQI_Section_title;
            String migration_Tool_Section_title = Label.Migration_Tool_Section_title;
            String enable_Trigger_helptext = Label.Enable_Trigger_helptext;
            String aqi_Edition_title = Label.AQI_Edition_title;
            String edit_Archived_Article_label = Label.Edit_Archived_Article_label;
            String edit_Draft_Article_label = Label.Edit_Draft_Article_label;

            //WarningPageNewAQI Visualforce page
            String warning_on_create_AQI_alert = Label.Warning_on_create_AQI_alert;
        } catch (Exception e) {
            success = false;
        }

        return success;

    }
}
