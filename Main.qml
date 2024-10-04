import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Customer Car Management"

    // Variable to hold error messages
    property string errorMessage: ""
    // Variable to hold the selected customer data
    property var selectedCustomer: null

    Column {
        anchors.fill: parent
        spacing: 10
        padding: 20
        height: parent.height


        // Button Row
        Row {
            width: parent.width
            spacing: 10
            padding: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                text: "Add Customer"
                width: (parent.width - 50) * 0.5
                onClicked: {
                    addCustomerDialog.open();
                }
            }
            Button {
                text: "Add Car to Customer"
                width: (parent.width - 50) * 0.5
                onClicked: {
                    addCarDialog.open();
                }
            }
        }

        // Add Customer Dialog
        Dialog {
            id: addCustomerDialog
            title: "Add Customer"
            width: parent.width
            height: parent.height
            standardButtons: Dialog.Ok | Dialog.Cancel
            contentItem: Column {
                spacing: 10
                padding: 30
                anchors.fill: parent

                Row {
                    spacing: 10
                    Label { text: "Customer ID:" }
                    TextField {
                        id: customerIdField
                        placeholderText: "Enter Customer ID"
                        width: 200
                    }
                }

                Text {
                    id: dialogErrorDisplay
                    text: errorMessage
                    color: "red"
                    visible: errorMessage !== ""
                }

                Button {
                    text: "Add Customer"
                    onClicked: {
                        if (customerIdField.text !== "") {
                            if (!customerModel.customerExists(customerIdField.text)) {
                                customerModel.addCustomer(customerIdField.text);
                                customerIdField.clear();
                                errorMessage = "";
                                addCustomerDialog.close();
                            } else {
                                errorMessage = "Customer ID already exists.";
                            }
                        } else {
                            errorMessage = "Customer ID cannot be empty.";
                        }
                    }
                }
            }

            onAccepted: {
                errorMessage = "";
            }

            onRejected: {
                errorMessage = "";
            }
        }

        // Add Car Dialog
        Dialog {
            id: addCarDialog
            title: "Add Car to Selected Customer"
            width: parent.width
            height: parent.height
            standardButtons: Dialog.Ok | Dialog.Cancel
            contentItem: Column {
                spacing: 10
                padding: 30
                anchors.fill: parent

                // Select Customer using ComboBox
                Row {
                    spacing: 10
                    Label { text: "Choose Customer ID:" }
                    ComboBox {
                        id: customerComboBox
                        model: customerModel
                        textRole: "customerId"
                        onCurrentIndexChanged: {
                            customerModel.selectCustomer(currentIndex);
                        }
                    }
                }

                Row {
                    spacing: 10
                    Label { text: "Car Model:" }
                    ComboBox {
                        id: carModelComboBox
                        model: ["Model A", "Model B", "Model C"]
                    }
                }

                Row {
                    spacing: 10
                    Label { text: "Airbags:" }
                    ComboBox {
                        id: airbagComboBox
                        model: ["1", "2"]
                    }
                }

                Text {
                    id: carDialogErrorDisplay
                    text: errorMessage
                    color: "red"
                    visible: errorMessage !== ""
                }

                Button {
                    text: "Add Car"
                    onClicked: {
                        if (carModelComboBox.currentText !== "" && airbagComboBox.currentText !== "") {
                            var airbags = parseInt(airbagComboBox.currentText);
                            customerModel.addCarToCustomer(carModelComboBox.currentText, airbags);
                            carModelComboBox.currentIndex = -1;
                            airbagComboBox.currentIndex = -1;
                            errorMessage = "";
                            addCarDialog.close();
                        } else {
                            errorMessage = "Please fill in all fields.";
                        }
                    }
                }
            }

            onAccepted: {
                errorMessage = "";
            }

            onRejected: {
                errorMessage = "";
            }
        }

        // A container that includes both the headers and the TableView
        Column {
            width: parent.width - 40
            height: parent.height

            // Header
            Rectangle {
                width: parent.width
                height: 40
                color: "lightgray"
                border.color: "black"
                Row {
                    spacing: 10
                    width: parent.width
                    height: parent.height

                    Text {
                        text: "Customers"
                        anchors.centerIn: parent
                    }
                }
            }

            TableView {
                id: tableView
                width: parent.width
                height: parent.height - 40
                model: customerModel
                clip: true

                // Specify column width using columnWidthProvider
                columnWidthProvider: function (column) {
                    if (column === 0) {
                        return parent.width;
                    }
                    return 150; // Default width for other columns
                }

                // Delegate for displaying customer data
                delegate: Rectangle {
                    width: tableView.columnWidth
                    height: 50
                    color: "#F7D358"
                    border.color: "lightgray"

                    Row {
                        spacing: 10
                        width: parent.width
                        height: parent.height

                        Text {
                            anchors.centerIn: parent
                            text: model.customerId
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedCustomer = model;
                            console.log(selectedCustomer.customerId)
                            carTableView.updateCarList();
                            carDialog.open();
                        }
                    }
                }
            }
        }

        // Dialog for displaying the selected customer's cars
        Dialog {
            id: carDialog
            title: "Selected Customer's Cars"
            width: parent.width
            height: parent.height
            standardButtons: Dialog.Ok | Dialog.Cancel
            contentItem: Column {
                spacing: 10
                padding: 20
                anchors.fill: parent

                Text {
                    topPadding: 10
                    text: "Customer ID: " + (selectedCustomer ? selectedCustomer.customerId : "N/A")
                }

                Column {
                    id: carColumn
                    width: parent.width-40
                    height: parent.height

                    Rectangle {
                        width: carColumn.width
                        height: 40
                        color: "transparent"

                        Row {
                            width: carColumn.width
                            height: parent.height

                            // First Header: Model
                            Rectangle {
                                width: carColumn.width * 0.5
                                height: parent.height
                                color: "lightgray"
                                border.color: "black"
                                Text {
                                    anchors.centerIn: parent
                                    text: "Model"
                                }
                            }

                            // Second Header: Airbag Count
                            Rectangle {
                                width: carColumn.width * 0.5
                                height: parent.height
                                color: "lightgray"
                                border.color: "black"
                                Text {
                                    anchors.centerIn: parent
                                    text: "Airbag Count"
                                }
                            }
                        }
                    }

                    TableView {
                        id: carTableView
                        width: carColumn.width
                        height: parent.height - 40


                        model: ListModel {
                            id: carListModel
                        }

                        delegate: Row {
                            width: carColumn.width
                            height: 50

                            // Column for carModel
                            Rectangle {
                                width: carColumn.width * 0.5
                                height: 50
                                color: "#F7D358"
                                border.color: "lightgray"
                                Text {
                                    anchors.centerIn: parent
                                    text: model.carModel
                                }
                            }

                            // Column for airbags
                            Rectangle {
                                width: carColumn.width * 0.5
                                height: 50
                                color: "#F7D358"
                                border.color: "lightgray"
                                Text {
                                    anchors.centerIn: parent
                                    text: model.carAirbags
                                }
                            }
                        }

                        function updateCarList() {
                            carListModel.clear();

                            if (selectedCustomer.customerId >= 0) {
                                let models = selectedCustomer.carModels;
                                let airbags = selectedCustomer.airbagsList;

                                if (models.length > 0) {
                                    for (let i = 0; i < models.length; i++) {
                                        carListModel.append({ carModel: models[i], carAirbags: airbags[i] });
                                    }
                                }else {
                                    carListModel.append({
                                        carModel: "No Data",
                                        carAirbags: "No Data"
                                    });
                                }
                            } else {
                                console.log("No customer selected.");
                            }
                        }
                    }
                }
            }
        }
    }
}
