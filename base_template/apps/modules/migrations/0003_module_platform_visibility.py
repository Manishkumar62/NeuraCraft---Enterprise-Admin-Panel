from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('modules', '0002_remove_rolemodulepermission_can_add_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='module',
            name='available_on_mobile',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='module',
            name='available_on_web',
            field=models.BooleanField(default=True),
        ),
    ]
