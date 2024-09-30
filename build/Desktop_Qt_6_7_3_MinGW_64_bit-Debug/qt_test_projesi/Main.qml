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
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                text: "Open Add Customer"
                width: 150
                onClicked: {
                    addCustomerDialog.open();
                }
            }
            Button {
                text: "Open Add Car"
                width: 150
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

        // Display Customers and their Cars
        /*
        TableView {
            width: parent.width
            height: parent.height
            model: customerModel

            delegate: Row {
                spacing: 10
                height: 50

                Rectangle {
                    width: 200
                    height: 50
                    color: "lightgray"
                    Text {
                        anchors.centerIn: parent
                        text: model.customerId
                    }
                }

                Rectangle {
                    width: 400
                    height: 50
                    color: "lightblue"
                    Text {
                        anchors.centerIn: parent
                        text: model.cars
                    }
                }
            }
        }
        */

        // TableView to display customers
        TableView {
            width: parent.width
            height: parent.height
            model: customerModel
            clip: true



            // Columns for Customer ID
            delegate: Rectangle {
                color: "lightgray"
                border.color: "black"

                width: parent.width
                height: 50

                Row {
                    spacing: 10
                    anchors.fill: parent

                    Text {
                        anchors.centerIn: parent
                        text: model.customerId
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedCustomer = model
                        console.log(selectedCustomer.customerId)
                        carDialog.open()
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
                padding: 30
                anchors.fill: parent

                Text {
                    text: "Customer ID: " + (selectedCustomer ? selectedCustomer.customerId : "")
                }

                TableView {
                    id: carTableView
                    width: parent.width
                    height: parent.height
                    clip: true
                    model: ListModel {
                        Component.onCompleted: {
                            if (selectedCustomer) {
                                clear()
                                for (var i = 0; i < selectedCustomer.cars.length; i++) {
                                    console.log("Evet")
                                    append({
                                        "carModel": selectedCustomer.cars[i].model,
                                        "airbags": selectedCustomer.cars[i].airbags
                                    })
                                }
                            }
                        }
                    }

                    delegate: Row {
                        spacing: 10
                        height: 50

                        Rectangle {
                            width: 200
                            height: 50
                            color: "lightgray"
                            Text {
                                anchors.centerIn: parent
                                text: model.carModel
                            }
                        }

                        Rectangle {
                            width: 400
                            height: 50
                            color: "lightblue"
                            Text {
                                anchors.centerIn: parent
                                text: model.airbags
                            }
                        }
                    }
                }
            }
        }
    }
}
