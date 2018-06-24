// Replace labels to mock dashboard for fs vertical customers
var originalLabel = 'TICKETS SOLD';
var newLabel = 'TRANSACTIONS';
var labels = document.getElementsByClassName("type-label");
if (labels.length && labels.length > 0) {
    for(var i = 0; i < labels.length; i++)
    {
        labels[i].innerText = labels[i].innerText.replace(originalLabel, newLabel);
    }
}
