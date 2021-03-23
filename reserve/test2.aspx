﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="test2.aspx.cs" Inherits="reserve.test2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>HTML DOM</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
    .table {
        border: 1px solid #ccc;
        border-collapse: collapse;
    }
    .table th, .table td {
        border: 1px solid #ccc;
    }
    .table th, .table td {
        padding: 0.5rem;
    }
    .draggable {
        cursor: move;
        user-select: none;
    }
    .placeholder {
        background-color: #edf2f7;
        border: 2px dashed #cbd5e0;
    }
    .clone-list {
        border-top: 1px solid #ccc;
    }
    .clone-table {
        border-collapse: collapse;
        border: none;
    }
    .clone-table th, .clone-table td {
        border: 1px solid #ccc;
        border-top: none;
        padding: 0.5rem;
    }
    .dragging {
        background: #fff;
        border-top: 1px solid #ccc;
        z-index: 999;
    }

    .opac {
        background-color: rgba(255,0,0,.3);
    }
    </style>
<script>
function allowDrop(ev) {
  ev.preventDefault();
}

function drag(ev) {
  ev.dataTransfer.setData("text", ev.target.id);
}

function drop(ev) {
  ev.preventDefault();
  var data = ev.dataTransfer.getData("text");
  ev.target.appendChild(document.getElementById(data));
}
</script>
</head>
<body class="font-sans w-full">
    <div class="py-16 flex items-center justify-center">
        <table id="table" class="table">
            <thead>
                <tr>
                    <th data-type="number">No.</th>
                    <th>First name</th>
                    <th>Last name</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1</td>
                    <td>Andrea</td>
                    <td>Ross</td>
                </tr>
                <tr>
                    <td>2</td>
                    <td>Penelope</td>
                    <td>Mills</td>
                </tr>
                <tr>
                    <td>3</td>
                    <td>Sarah</td>
                    <td>Grant</td>
                </tr>
                <tr>
                    <td>4</td>
                    <td>Vanessa</td>
                    <td>Roberts</td>
                </tr>
                <tr>
                    <td id="test">5</td>
                    <td>Oliver</td>
                    <td>Alsop</td>
                </tr>
                <tr>
                    <td>6</td>
                    <td>Jennifer</td>
                    <td>Forsyth</td>
                </tr>
                <tr>
                    <td>7</td>
                    <td>Michelle</td>
                    <td>King</td>
                </tr>
                <tr>
                    <td>8</td>
                    <td>Steven</td>
                    <td>Kelly</td>
                </tr>
                <tr>
                    <td>9</td>
                    <td>Julian</td>
                    <td>Ferguson</td>
                </tr>
                <tr>
                    <td>10</td>
                    <td>Chloe</td>
                    <td>Ince</td>
                </tr>
            </tbody>
        </table>
    </div>
    <input type="button" value="click me" onclick="changeOpacity()" />
    <input class="tester opac" id="txt1" name="txt1" value="aerwerjnkaf" />
    <input class="tester" id="txt2" name="txt2" value="asdfasdfsadf" />
<script>
    function changeOpacity() {
        document.getElementsByClassName('tester').className = "opac";
    }
    function selectText() {
        var oTextbox1 = document.getElementById("txt2");
        oTextbox1.focus();
        oTextbox1.select();
    }
    document.addEventListener('DOMContentLoaded', function () {
        const table = document.getElementById('table');

        let draggingEle;
        let draggingRowIndex;
        let placeholder;
        let list;
        let isDraggingStarted = false;

        // The current position of mouse relative to the dragging element
        let x = 0;
        let y = 0;

        // Swap two nodes
        const swap = function (nodeA, nodeB) {
            const parentA = nodeA.parentNode;
            const siblingA = nodeA.nextSibling === nodeB ? nodeA : nodeA.nextSibling;

            // Move `nodeA` to before the `nodeB`
            nodeB.parentNode.insertBefore(nodeA, nodeB);

            // Move `nodeB` to before the sibling of `nodeA`
            parentA.insertBefore(nodeB, siblingA);
        };

        // Check if `nodeA` is above `nodeB`
        const isAbove = function (nodeA, nodeB) {
            // Get the bounding rectangle of nodes
            const rectA = nodeA.getBoundingClientRect();
            const rectB = nodeB.getBoundingClientRect();

            return (rectA.top + rectA.height / 2 < rectB.top + rectB.height / 2);
        };

        const cloneTable = function () {
            const rect = table.getBoundingClientRect();
            const width = parseInt(window.getComputedStyle(table).width);

            list = document.createElement('div');
            list.classList.add('clone-list');
            list.style.position = 'absolute';
            list.style.left = `${rect.left}px`;
            list.style.top = `${rect.top}px`;
            table.parentNode.insertBefore(list, table);

            // Hide the original table
            table.style.visibility = 'hidden';

            table.querySelectorAll('tr').forEach(function (row) {
                // Create a new table from given row
                const item = document.createElement('div');
                item.classList.add('draggable');

                const newTable = document.createElement('table');
                newTable.setAttribute('class', 'clone-table');
                newTable.style.width = `${width}px`;

                const newRow = document.createElement('tr');
                const cells = [].slice.call(row.children);
                cells.forEach(function (cell) {
                    const newCell = cell.cloneNode(true);
                    newCell.style.width = `${parseInt(window.getComputedStyle(cell).width)}px`;
                    newRow.appendChild(newCell);
                });

                newTable.appendChild(newRow);
                item.appendChild(newTable);
                list.appendChild(item);
            });
        };

        const mouseDownHandler = function (e) {
            // Get the original row
            const originalRow = e.target.parentNode;
            draggingRowIndex = [].slice.call(table.querySelectorAll('tr')).indexOf(originalRow);

            // Determine the mouse position
            x = e.clientX;
            y = e.clientY;

            // Attach the listeners to `document`
            document.addEventListener('mousemove', mouseMoveHandler);
            document.addEventListener('mouseup', mouseUpHandler);
        };

        const mouseMoveHandler = function (e) {
            if (!isDraggingStarted) {
                isDraggingStarted = true;

                cloneTable();

                draggingEle = [].slice.call(list.children)[draggingRowIndex];
                draggingEle.classList.add('dragging');

                // Let the placeholder take the height of dragging element
                // So the next element won't move up
                placeholder = document.createElement('div');
                placeholder.classList.add('placeholder');
                draggingEle.parentNode.insertBefore(placeholder, draggingEle.nextSibling);
                placeholder.style.height = `${draggingEle.offsetHeight}px`;
            }

            // Set position for dragging element
            draggingEle.style.position = 'absolute';
            draggingEle.style.top = `${draggingEle.offsetTop + e.clientY - y}px`;
            draggingEle.style.left = `${draggingEle.offsetLeft + e.clientX - x}px`;

            // Reassign the position of mouse
            x = e.clientX;
            y = e.clientY;

            // The current order
            // prevEle
            // draggingEle
            // placeholder
            // nextEle
            const prevEle = draggingEle.previousElementSibling;
            const nextEle = placeholder.nextElementSibling;

            // The dragging element is above the previous element
            // User moves the dragging element to the top
            // We don't allow to drop above the header 
            // (which doesn't have `previousElementSibling`)
            if (prevEle && prevEle.previousElementSibling && isAbove(draggingEle, prevEle)) {
                // The current order    -> The new order
                // prevEle              -> placeholder
                // draggingEle          -> draggingEle
                // placeholder          -> prevEle
                swap(placeholder, draggingEle);
                swap(placeholder, prevEle);
                return;
            }

            // The dragging element is below the next element
            // User moves the dragging element to the bottom
            if (nextEle && isAbove(nextEle, draggingEle)) {
                // The current order    -> The new order
                // draggingEle          -> nextEle
                // placeholder          -> placeholder
                // nextEle              -> draggingEle
                swap(nextEle, placeholder);
                swap(nextEle, draggingEle);
            }
        };

        const mouseUpHandler = function () {
            // Remove the placeholder
            placeholder && placeholder.parentNode.removeChild(placeholder);

            draggingEle.classList.remove('dragging');
            draggingEle.style.removeProperty('top');
            draggingEle.style.removeProperty('left');
            draggingEle.style.removeProperty('position');

            // Get the end index
            const endRowIndex = [].slice.call(list.children).indexOf(draggingEle);

            isDraggingStarted = false;

            // Remove the `list` element
            list.parentNode.removeChild(list);

            // Move the dragged row to `endRowIndex`
            let rows = [].slice.call(table.querySelectorAll('tr'));
            draggingRowIndex > endRowIndex
                ? rows[endRowIndex].parentNode.insertBefore(rows[draggingRowIndex], rows[endRowIndex])
                : rows[endRowIndex].parentNode.insertBefore(rows[draggingRowIndex], rows[endRowIndex].nextSibling);

            // Bring back the table
            table.style.removeProperty('visibility');

            // Remove the handlers of `mousemove` and `mouseup`
            document.removeEventListener('mousemove', mouseMoveHandler);
            document.removeEventListener('mouseup', mouseUpHandler);

            alert(table.rows[endRowIndex].cells[0].id);
        };

        table.querySelectorAll('tr').forEach(function (row, index) {
            // Ignore the header
            // We don't want user to change the order of header
            if (index === 0) {
                return;
            }

            //const firstCell = row.firstElementChild;
            const firstCell = row.children[1];
            firstCell.classList.add('draggable');
            firstCell.addEventListener('mousedown', mouseDownHandler);
        });
    });
</script>
</body>
</html>
