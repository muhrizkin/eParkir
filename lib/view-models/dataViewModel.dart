import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eparkir/services/checkConnection.dart';
import 'package:eparkir/services/firestore/databaseReference.dart';
import 'package:eparkir/widgets/common/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class DataViewModel extends BaseViewModel {
  bool sortNameAsc = true;
  bool sortNisAsc = true;
  bool sortKelasAsc = true;
  bool sortAsc = true;
  int sortColumnIndex;

  String orderByValue;

  String textSearch;

  bool showSearch = false;
  TextEditingController _tecSearch;
  FocusNode _searchNode;
  CheckConnection checkConnection;
  Snackbar _snackbar = Snackbar();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  get tecClear => _tecSearch.clear();
  get tecSearch => _tecSearch;
  get searchNode => _searchNode;
  get searchUnfocus => _searchNode.unfocus();
  get scaffoldKey => _scaffoldKey;

  void initState() {
    _tecSearch = new TextEditingController();
    _searchNode = FocusNode();
    _tecSearch.clear();
    textSearch = "";
    checkConnection = CheckConnection();
    notifyListeners();
  }

  void addDataToFirestore(nis, nama, kelas, context) async {
    checkConnection.checkConnection().then((_) async {
      if (checkConnection.hasConnection) {
        var test2 = await databaseReference
            .collection('siswa')
            .where('nis', isEqualTo: nis)
            .getDocuments();

        if (test2.documents.length == 0) {
          DocumentReference documentReference =
              await databaseReference.collection('siswa').add({
            'nama': nama,
            'nis': nis,
            'kelas': kelas,
            'level': 0,
            'hadir': false,
            'login': false,
            'nisSearch': setSearchParam(nis),
          });
          return documentReference;
        } else {
          return _scaffoldKey.currentState.showSnackBar(snackbar);
        }
      } else {
        return _scaffoldKey.currentState.showSnackBar(_snackbar.snackbarNoInet);
      }
    }).then((_) {
      Navigator.pop(context);
    });
  }

  void editDataToFirestore(nis, nama, kelas, id, context) async {
    checkConnection.checkConnection().then((_) {
      if (checkConnection.hasConnection) {
        return Firestore.instance.collection('siswa').document(id).updateData({
          'nama': nama,
          'nis': nis,
          'kelas': kelas,
          'nisSearch': setSearchParam(nis),
        });
      } else {
        return _scaffoldKey.currentState.showSnackBar(_snackbar.snackbarNoInet);
      }
    }).then((_) {
      Navigator.pop(context);
    });
  }

  void hapusDataToFirestore(id, context) async {
    checkConnection.checkConnection().then((_) {
      if (checkConnection.hasConnection) {
        return Firestore.instance.collection('siswa').document(id).delete();
      } else {
        return _scaffoldKey.currentState.showSnackBar(_snackbar.snackbarNoInet);
      }
    }).then((_) {
      Navigator.pop(context);
    });
  }

  final snackbar = SnackBar(
    content: Text("NIS Sudah Ada"),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: "Undo",
      textColor: Colors.black,
      onPressed: () {
        print('Pressed');
      },
    ),
  );

  setSearchParam(String caseNumber) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  void tapped(nis, nama, kelas, context, idUser) {
    final height = MediaQuery.of(context).size.height;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detail Data Siswa'),
            content: Container(
              height: height / 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(nis.toString()),
                  Text(nama),
                  Text(kelas),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                child: Text("Hapus"),
                onPressed: () => hapusData(idUser, context),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text("Ubah"),
                onPressed: () {
                  editData(nis, nama, kelas, height, idUser, context);
                },
              ),
            ],
          );
        });
  }

  void hapusData(idUser, context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hapus Data"),
            content: Text('Apakah Anda Yakin ?'),
            actions: <Widget>[
              FlatButton(
                color: Colors.blue,
                child: Text("Batal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: Colors.green,
                child: Text("Hapus"),
                onPressed: () {
                  hapusDataToFirestore(idUser, context);
                },
              )
            ],
          );
        });
  }

  void editData(nis, nama, kelas, height, idUser, context) {
    TextEditingController controllerNis =
        TextEditingController(text: nis.toString());
    TextEditingController controllerNama = TextEditingController(text: nama);
    TextEditingController controllerKelas = TextEditingController(text: kelas);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Ubah Data"),
            content: Container(
              height: height / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    maxLength: 8,
                    keyboardType: TextInputType.number,
                    controller: controllerNis,
                  ),
                  TextField(
                    controller: controllerNama,
                  ),
                  TextField(
                    controller: controllerKelas,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                child: Text("Simpan"),
                onPressed: () {
                  editDataToFirestore(controllerNis.text, controllerNama.text,
                      controllerKelas.text, idUser, context);
                },
              )
            ],
          );
        });
  }

  void addData(height, context) {
    TextEditingController controllerNis = TextEditingController();
    TextEditingController controllerNama = TextEditingController();
    TextEditingController controllerKelas = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tambah Data"),
            content: Container(
              height: height / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    maxLength: 8,
                    keyboardType: TextInputType.number,
                    controller: controllerNis,
                  ),
                  TextField(
                    controller: controllerNama,
                  ),
                  TextField(
                    controller: controllerKelas,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.blue,
                child: Text("Tambah"),
                onPressed: () {
                  addDataToFirestore(controllerNis.text, controllerNama.text,
                      controllerKelas.text, context);
                },
              )
            ],
          );
        });
  }
}