import { useState, useEffect } from 'react'
import { User, Lock, Mail, LogIn, UserPlus, Server } from 'lucide-react'
import './index.css'

const API_URL = 'http://localhost:3001/api';

function App() {
  const [isLogin, setIsLogin] = useState(true);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [user, setUser] = useState(null);
  const [stats, setStats] = useState(null);
  const [rankings, setRankings] = useState([]);
  const [showRankings, setShowRankings] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      fetchProfile(token);
    }
    fetchStats();
    fetchRankings();
  }, []);

  const fetchProfile = async (token) => {
    try {
      const res = await fetch(`${API_URL}/profile`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setUser(data);
      } else {
        localStorage.removeItem('token');
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchStats = async () => {
    try {
      const res = await fetch(`${API_URL}/stats`);
      if (res.ok) {
        const data = await res.json();
        setStats(data);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchRankings = async () => {
    try {
      const res = await fetch(`${API_URL}/rankings`);
      if (res.ok) {
        const data = await res.json();
        setRankings(data);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    const endpoint = isLogin ? '/login' : '/register';
    const body = isLogin ? { username, password } : { username, password, email };

    try {
      const res = await fetch(`${API_URL}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      
      const data = await res.json();
      
      if (!res.ok) {
        setError(data.error || 'Erro desconhecido');
        return;
      }

      if (isLogin) {
        localStorage.setItem('token', data.token);
        fetchProfile(data.token);
      } else {
        setSuccess('Conta criada com sucesso! Faça login.');
        setIsLogin(true);
      }
    } catch (err) {
      setError('Erro de conexão com o servidor');
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
  };

  if (user) {
    return (
      <div className="dashboard-container">
        <div className="logo-section">
          <h1>Aldebaran</h1>
          <p>Painel de Gestão Alpha</p>
        </div>
        
        <div className="profile-card">
          <div className="avatar">
            {user.username.charAt(0).toUpperCase()}
          </div>
          <h2>Bem-vindo, {user.username}</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '15px' }}>
            ID da Conta: #{user.id}
          </p>
          
          <div className="stat-box">
            <div className="stat-item">
              <span className="stat-label">Servidor</span>
              <span className="stat-value" style={{ color: '#00e676' }}>
                <Server size={14} style={{ display: 'inline', marginRight: '5px' }}/> 
                {stats ? stats.serverStatus : 'Online'}
              </span>
            </div>
            <div className="stat-item">
              <span className="stat-label">Jogadores Ativos</span>
              <span className="stat-value">{stats ? stats.activePlayers : '---'}</span>
            </div>
          </div>

          <button className="btn-primary" onClick={() => setShowRankings(true)} style={{ marginTop: '20px', background: 'var(--secondary)' }}>
            Ver Global Rankings
          </button>

          <button className="btn-primary" onClick={logout} style={{ marginTop: '10px', background: '#e53935' }}>
            Sair
          </button>
        </div>
      </div>
    );
  }

  if (showRankings) {
    return (
      <div className="dashboard-container" style={{ maxWidth: '600px' }}>
        <div className="logo-section">
          <h1>Global Rankings</h1>
          <p>Top 10 Hunters do Servidor</p>
        </div>
        
        <div style={{ background: 'rgba(0,0,0,0.3)', borderRadius: '12px', padding: '15px', marginTop: '20px' }}>
          <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
                <th style={{ padding: '10px' }}>Rank</th>
                <th style={{ padding: '10px' }}>Nome</th>
                <th style={{ padding: '10px' }}>Vocation</th>
                <th style={{ padding: '10px' }}>Level</th>
              </tr>
            </thead>
            <tbody>
              {rankings.map((r, idx) => (
                <tr key={idx} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                  <td style={{ padding: '10px', color: idx < 3 ? '#fbbf24' : '#fff' }}>#{idx + 1}</td>
                  <td style={{ padding: '10px', fontWeight: 'bold' }}>{r.name}</td>
                  <td style={{ padding: '10px', color: '#9ca3af' }}>Nen {r.vocation}</td>
                  <td style={{ padding: '10px', color: '#3b82f6', fontWeight: 'bold' }}>{r.level}</td>
                </tr>
              ))}
              {rankings.length === 0 && (
                <tr>
                  <td colSpan="4" style={{ padding: '20px', textAlign: 'center' }}>Nenhum dado encontrado.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        <button className="btn-primary" onClick={() => setShowRankings(false)} style={{ marginTop: '30px' }}>
          Voltar
        </button>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <div className="logo-section">
        <h1>Aldebaran</h1>
        <p>Acesso Restrito - Alpha Test</p>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="input-group">
          <label>Nome de Usuário</label>
          <div className="input-wrapper">
            <User className="input-icon" />
            <input 
              type="text" 
              placeholder="Digite seu usuário" 
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>
        </div>

        {!isLogin && (
          <div className="input-group">
            <label>E-mail</label>
            <div className="input-wrapper">
              <Mail className="input-icon" />
              <input 
                type="email" 
                placeholder="exemplo@email.com" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required={!isLogin}
              />
            </div>
          </div>
        )}

        <div className="input-group">
          <label>Senha</label>
          <div className="input-wrapper">
            <Lock className="input-icon" />
            <input 
              type="password" 
              placeholder="••••••••" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
        </div>

        {error && <p className="error-message">{error}</p>}
        {success && <p className="success-message">{success}</p>}

        <button type="submit" className="btn-primary" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
          {isLogin ? <><LogIn size={18} /> Entrar no Painel</> : <><UserPlus size={18} /> Criar Conta Alpha</>}
        </button>
      </form>

      <div className="toggle-form">
        {isLogin ? (
          <p>Não tem uma conta? <span onClick={() => { setIsLogin(false); setError(''); setSuccess(''); }}>Crie uma agora</span></p>
        ) : (
          <p>Já possui acesso? <span onClick={() => { setIsLogin(true); setError(''); setSuccess(''); }}>Faça Login</span></p>
        )}
      </div>

      <div style={{ textAlign: 'center', marginTop: '20px' }}>
        <button onClick={() => setShowRankings(true)} style={{ background: 'transparent', border: '1px solid rgba(255,255,255,0.2)', color: '#fff', padding: '10px 20px', borderRadius: '8px', cursor: 'pointer', transition: 'all 0.2s' }} onMouseOver={e => e.target.style.background='rgba(255,255,255,0.1)'} onMouseOut={e => e.target.style.background='transparent'}>
          🏆 Ver Rankings Globais
        </button>
      </div>
    </div>
  )
}

export default App
