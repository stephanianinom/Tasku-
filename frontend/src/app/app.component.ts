import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  template: `
    <div class="container">
      <h1 class="title">Bienvenido a Tasku</h1>
      <p class="subtitle">proyecto en desarrollo</p>
      <div class="emoji">🔧</div>
    </div>
  `,
  styles: []
})
export class AppComponent {
}
