import { Injectable } from '@angular/core';
import { UsuarioModel } from './../models/usuario.model';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class UsuarioService {

  url = environment.apiUrl;

  constructor(private _http: HttpClient) {}

  // Obtener lista completa de usuarios
  getUsers() {
    return this._http.get(`${this.url}/users`)
  }

  // Crear nuevo usuario
  newUser(usuario: UsuarioModel) {
    return this._http.post(`${this.url}/user`, usuario )
  }

  // Encontrar un usuario a través de su id
  findUser(id:string) {
    return this._http.get(`${this.url}/user/${id}`)
  }

  // Actualizar usuario
  updateUser(usuario: UsuarioModel) {
    return this._http.put(`${this.url}/user/${usuario._id}`, usuario)
  }

  // Eliminar usuario
  borrarUser(id:string) {
    return this._http.delete(`${this.url}/user/${id}`)
  }
}
