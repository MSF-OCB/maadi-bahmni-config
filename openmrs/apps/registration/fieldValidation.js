Bahmni.Registration.customValidator = {
    "age.days": {
        method: function (name, value) {
            return value >= 0;
        },
        errorMessage: "REGISTRATION_AGE_ERROR_KEY"
    },
    "In-scope Date": {
        method:function (name,value,personAttributeDetails) {
            return value <= new Date();
        },
        errorMessage: "REGISTRATION_IN_SCOPE_DATE_ERROR_KEY"
    }
};
